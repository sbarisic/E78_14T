namespace Iaw8p40.Calculator;

public sealed class CalibrationCalculator
{
    private const int LoadAxisAddress = 0x9291;
    private const int LoadAxisCountAddress = 0x929A;
    private const int RpmAxisAddress = 0x929E;
    private const int RpmAxisCountAddress = 0x92CE;
    private const int CtsAxisAddress = 0x92CF;
    private const int CtsAxisCountAddress = 0x92D8;
    private const int IatAxisAddress = 0x92D9;
    private const int IatAxisCountAddress = 0x92E2;

    private readonly RomImage _rom;
    private readonly CalculationAssumptions _assumptions;

    public CalibrationCalculator(RomImage rom, CalculationAssumptions assumptions)
    {
        _rom = rom;
        _assumptions = assumptions;
    }

    public CalculationResult Calculate(CalculationInputs input)
    {
        List<AxisTrace> axisTraces = new();
        List<LookupTrace> lookupTraces = new();
        List<string> warnings = new();

        ResolvedAxes axes = ResolveAxes(input, axisTraces, lookupTraces, warnings);
        SparkResult spark = CalculateSpark(input, axes, lookupTraces, warnings);
        FuelResult fuel = CalculateFuel(input, axes, lookupTraces, warnings);

        if (_assumptions.TimerTickMicroseconds is not null)
        {
            warnings.Add(
                $"Timer conversion uses the configured {_assumptions.TimerTickMicroseconds.Value:0.###} us/tick assumption. Raw timer ticks remain authoritative until the E-clock and prescaler are proven."
            );
        }

        return new CalculationResult
        {
            BinPath = _rom.SourcePath,
            BinSha256 = _rom.Sha256,
            Axes = axes,
            Spark = spark,
            Fuel = fuel,
            AxisTraces = axisTraces,
            LookupTraces = lookupTraces,
            Warnings = warnings.Distinct(StringComparer.Ordinal).ToList()
        };
    }

    private ResolvedAxes ResolveAxes(
        CalculationInputs input,
        List<AxisTrace> axisTraces,
        List<LookupTrace> lookupTraces,
        List<string> warnings)
    {
        ushort period;
        int resolvedRpm;
        if (input.EnginePeriodTicks is not null)
        {
            period = (ushort)input.EnginePeriodTicks.Value;
            resolvedRpm = (int)Math.Round(
                _assumptions.RpmClockNumerator / (double)period,
                MidpointRounding.AwayFromZero
            );
        }
        else
        {
            period = RpmToPeriod(input.Rpm);
            resolvedRpm = input.Rpm;
        }

        ushort rpmAxis;
        if (input.RpmAxisQ8_8 is not null)
        {
            rpmAxis = (ushort)input.RpmAxisQ8_8.Value;
        }
        else
        {
            int rpmCount = _rom.ReadByte(RpmAxisCountAddress);
            rpmAxis = RomLookup.PeriodAxisLookup(
                _rom,
                RpmAxisAddress,
                rpmCount,
                period,
                out AxisTrace trace,
                "RPM period axis 0x929E"
            );
            axisTraces.Add(trace);
        }

        byte? loadDelta = input.LoadDeltaByte is null ? null : (byte)input.LoadDeltaByte.Value;
        byte? loadFactor = null;
        ushort loadAircharge;
        ushort loadAxis;

        if (input.LoadAxisQ8_8 is not null || input.LoadIndex is not null)
        {
            loadAxis = input.LoadAxisQ8_8 is not null
                ? (ushort)input.LoadAxisQ8_8.Value
                : FixedPoint.FromIndex(input.LoadIndex!.Value);

            if (input.LoadAirchargeWord00CE is not null)
            {
                loadAircharge = (ushort)input.LoadAirchargeWord00CE.Value;
            }
            else
            {
                loadAircharge = (ushort)(loadAxis >> 1);
                warnings.Add(
                    "loadAirchargeWord00CE was inferred as loadAxisQ8_8 / 2. Supply it explicitly when using the full fuel path, especially near the 0x07FF load-axis clamp."
                );
            }
        }
        else
        {
            int loadCount = _rom.ReadByte(LoadAxisCountAddress);
            ushort loadHelperAxis = RomLookup.AxisLookupU8(
                _rom,
                LoadAxisAddress,
                loadCount,
                loadDelta!.Value,
                out AxisTrace trace,
                "Processed load-delta axis 0x9291"
            );
            axisTraces.Add(trace);

            loadFactor = RomLookup.Interp2DU8(
                _rom,
                0x9187,
                9,
                9,
                24,
                loadHelperAxis,
                rpmAxis,
                out LookupTrace lookup,
                "Load/air-charge factor 0x9187"
            );
            lookupTraces.Add(lookup);

            loadAircharge = (ushort)(loadFactor.Value << 2);
            loadAxis = (ushort)Math.Min(loadAircharge << 1, 0x07FF);
        }

        ushort iatAxis = ResolveTemperatureAxis(
            input.IatAxis2038Q8_8,
            input.IatAxisIndex,
            input.IatProcessedByte,
            IatAxisAddress,
            IatAxisCountAddress,
            "IAT-like axis 0x92D9",
            axisTraces
        );

        ushort ctsAxis = ResolveTemperatureAxis(
            input.CtsAxis203CQ8_8,
            input.CtsAxisIndex,
            input.CtsProcessedByte,
            CtsAxisAddress,
            CtsAxisCountAddress,
            "CTS-like axis 0x92CF",
            axisTraces
        );

        ushort iatSparkAxis = unchecked((ushort)(iatAxis << 1));
        ushort ctsSparkAxis = unchecked((ushort)(ctsAxis << 1));

        warnings.Add(
            "RPM is accepted as a physical input, but load and temperature are represented by firmware-normalized indices or processed bytes because exact MAP/IAT/CTS transfer functions are not yet proven."
        );

        return new ResolvedAxes
        {
            Rpm = resolvedRpm,
            EnginePeriodTicks = period,
            RpmAxisQ8_8 = rpmAxis,
            RpmAxisIndex = FixedPoint.ToIndex(rpmAxis),
            LoadDeltaByte = loadDelta,
            LoadAirchargeFactorRaw = loadFactor,
            LoadAirchargeWord00CE = loadAircharge,
            LoadAxisQ8_8 = loadAxis,
            LoadAxisIndex = FixedPoint.ToIndex(loadAxis),
            IatProcessedByte = input.IatProcessedByte is null ? null : (byte)input.IatProcessedByte.Value,
            IatAxis2038Q8_8 = iatAxis,
            IatSparkAxis203AQ8_8 = iatSparkAxis,
            IatAxisIndex = FixedPoint.ToIndex(iatAxis),
            CtsProcessedByte = input.CtsProcessedByte is null ? null : (byte)input.CtsProcessedByte.Value,
            CtsAxis203CQ8_8 = ctsAxis,
            CtsSparkAxis203EQ8_8 = ctsSparkAxis,
            CtsAxisIndex = FixedPoint.ToIndex(ctsAxis)
        };
    }

    private ushort ResolveTemperatureAxis(
        int? directQ8_8,
        double? directIndex,
        int? processedByte,
        int axisAddress,
        int countAddress,
        string name,
        List<AxisTrace> traces)
    {
        if (directQ8_8 is not null)
        {
            return (ushort)directQ8_8.Value;
        }

        if (directIndex is not null)
        {
            return FixedPoint.FromIndex(directIndex.Value);
        }

        int count = _rom.ReadByte(countAddress);
        ushort forward = RomLookup.AxisLookupU8(
            _rom,
            axisAddress,
            count,
            (byte)processedByte!.Value,
            out AxisTrace forwardTrace,
            name
        );

        ushort maximum = (ushort)((count - 1) << 8);
        ushort inverted = unchecked((ushort)(maximum - forward));
        traces.Add(forwardTrace with
        {
            Name = name + " (forward before firmware inversion)",
            Inverted = false
        });
        traces.Add(new AxisTrace(
            name + " (firmware-inverted result)",
            axisAddress,
            count,
            processedByte.Value,
            inverted,
            FixedPoint.Integer(inverted),
            Math.Min(FixedPoint.Integer(inverted) + 1, count - 1),
            FixedPoint.Fraction(inverted),
            0,
            0,
            true
        ));
        return inverted;
    }

    private SparkResult CalculateSpark(
        CalculationInputs input,
        ResolvedAxes axes,
        List<LookupTrace> traces,
        List<string> warnings)
    {
        bool rpmOnly = (input.OperatingModeFlagsA9 & 0x20) != 0;
        int baseAddress;
        string tableName;
        int baseRaw;
        int signedOffset = 0;

        if (rpmOnly)
        {
            baseAddress = 0x8C19;
            tableName = "RPM-only/WOT-bypass 0x8C19";
            baseRaw = RomLookup.Interp1DU8(
                _rom,
                baseAddress,
                24,
                axes.RpmAxisQ8_8,
                out LookupTrace trace,
                tableName
            );
            traces.Add(trace);
        }
        else
        {
            bool highDefaultBank = input.BankSelector20B1 != 0;
            baseAddress = highDefaultBank ? 0x8A69 : 0x8B41;
            tableName = highDefaultBank ? "Spark bank A/default 0x8A69" : "Spark bank B/alternate 0x8B41";
            baseRaw = RomLookup.Interp2DU8(
                _rom,
                baseAddress,
                9,
                9,
                24,
                axes.LoadAxisQ8_8,
                axes.RpmAxisQ8_8,
                out LookupTrace trace,
                tableName
            );
            traces.Add(trace);

            if ((input.SparkModeFlagsA2 & 0x02) != 0)
            {
                signedOffset = _rom.ReadSByte(0x8A68);
            }
        }

        int baseWithOffset = baseRaw + signedOffset;

        sbyte ctsCorrection = RomLookup.Interp2DS8(
            _rom,
            0x8D15,
            9,
            9,
            17,
            axes.LoadAxisQ8_8,
            axes.CtsSparkAxis203EQ8_8,
            out LookupTrace ctsTrace,
            "CTS/load spark correction 0x8D15"
        );
        traces.Add(ctsTrace);

        sbyte iatCorrection = RomLookup.Interp2DS8(
            _rom,
            0x8C7C,
            9,
            9,
            17,
            axes.LoadAxisQ8_8,
            axes.IatSparkAxis203AQ8_8,
            out LookupTrace iatTrace,
            "IAT/load spark correction 0x8C7C"
        );
        traces.Add(iatTrace);

        int core = baseWithOffset + ctsCorrection + iatCorrection;
        int unclamped = core + input.AdditionalSparkRaw;
        int command = input.ClampSparkCommandTo0Through127 ? Math.Clamp(unclamped, 0, 127) : unclamped;

        warnings.Add(
            "Spark output is exact for the decoded 0x48D8 base + CTS + IAT path. additionalSparkRaw represents later mode/state corrections; history-dependent slew limiting and event scheduling are not simulated."
        );

        return new SparkResult
        {
            SelectedBaseTable = tableName,
            SelectedBaseAddress = baseAddress,
            RpmOnlyBypassMode = rpmOnly,
            BaseTableRaw = baseRaw,
            OptionalSignedOffsetRaw = signedOffset,
            BaseWithOffsetRaw = baseWithOffset,
            CtsLoadCorrectionRaw = ctsCorrection,
            IatLoadCorrectionRaw = iatCorrection,
            CoreAccumulatorRaw = core,
            CoreAccumulatorDegrees = core * _assumptions.SparkDegreesPerRawCount,
            AdditionalSparkRaw = input.AdditionalSparkRaw,
            UnclampedCommandRaw = unclamped,
            CommandRaw = command,
            CommandDegrees = command * _assumptions.SparkDegreesPerRawCount,
            CommandWasClamped = command != unclamped
        };
    }

    private FuelResult CalculateFuel(
        CalculationInputs input,
        ResolvedAxes axes,
        List<LookupTrace> traces,
        List<string> warnings)
    {
        sbyte correctionA = RomLookup.Interp2DS8(
            _rom,
            0x802B,
            9,
            9,
            24,
            axes.IatAxis2038Q8_8,
            axes.RpmAxisQ8_8,
            out LookupTrace correctionATrace,
            "Signed IAT/RPM correction A 0x802B"
        );
        traces.Add(correctionATrace);

        sbyte correctionB = RomLookup.Interp2DS8(
            _rom,
            0x8103,
            9,
            9,
            24,
            axes.IatAxis2038Q8_8,
            axes.RpmAxisQ8_8,
            out LookupTrace correctionBTrace,
            "Signed IAT/RPM correction B 0x8103"
        );
        traces.Add(correctionBTrace);

        (sbyte trim, int trimAddress, string trimName) = SelectFuelTrim(input, axes, traces);

        string mode = input.FuelMode.Trim().ToLowerInvariant();
        if (mode == "apply-trim-only")
        {
            ushort initial = (ushort)input.BaseFuelPulseRaw;
            ushort afterTrimOnly = FixedPoint.ApplySignedByteFraction(initial, trim);
            double? ms = ToMilliseconds(afterTrimOnly);

            warnings.Add(
                "Fuel mode apply-trim-only starts from baseFuelPulseRaw and applies only the code-confirmed signed quantity trim. IAT/RPM correction outputs are reported but are not folded into the pulse because their complete upstream state terms are not supplied in this mode."
            );

            return new FuelResult
            {
                Mode = mode,
                SelectedTrimTable = trimName,
                SelectedTrimAddress = trimAddress,
                IatRpmCorrectionARaw = correctionA,
                IatRpmCorrectionBRaw = correctionB,
                SignedQuantityTrimRaw = trim,
                SignedQuantityTrimPercent = trim * 100.0 / 256.0,
                InputBasePulseRaw = initial,
                BaseBeforeBlendRaw = initial,
                BaseAfterBlendRaw = initial,
                AfterSignedTrimRaw = afterTrimOnly,
                AfterAdaptiveTrimRaw = afterTrimOnly,
                AfterWarmupRaw = afterTrimOnly,
                AfterAfterstartRaw = afterTrimOnly,
                AfterTransientStackRaw = afterTrimOnly,
                AfterPeriodLimitRaw = afterTrimOnly,
                AfterFuelMultiplierRaw = afterTrimOnly,
                CorrectedFuelCharge2051Raw = afterTrimOnly,
                AfterFastLambdaRaw = afterTrimOnly,
                BeforeHighLoadSupportRaw = afterTrimOnly,
                FinalDurationRaw = afterTrimOnly,
                FinalDurationMilliseconds = ms
            };
        }

        ushort sum204B = CalculateSummedFuelCorrection(input, correctionA);
        short sum204BSigned = unchecked((short)sum204B);
        ushort blend204E = CalculateFuelBlend(input, correctionB);

        ushort baseBeforeBlend = AddSignedAndClampNonnegative(axes.LoadAirchargeWord00CE, sum204B);
        ushort baseAfterBlend = FixedPoint.MultiplyQ8_8Rounded(baseBeforeBlend, blend204E);
        if (baseAfterBlend > 3_000)
        {
            baseAfterBlend = 3_000;
        }

        ushort afterTrim = FixedPoint.ApplySignedByteFraction(baseAfterBlend, trim);
        ushort afterAdaptive = ((input.AdaptiveTrim20B9 >> 8) & 0xFF) == 0x80
            ? afterTrim
            : FixedPoint.ApplyAdaptiveHighByteTrim(afterTrim, (ushort)input.AdaptiveTrim20B9);

        ushort afterWarmup = input.WarmupFuelCorrection2085 == 0
            ? afterAdaptive
            : FixedPoint.ApplyScaledPositiveFactor(afterAdaptive, (byte)input.WarmupFuelCorrection2085, 3);

        ushort afterAfterstart = input.AfterstartCorrectionC5 == 0
            ? afterWarmup
            : FixedPoint.ApplyScaledPositiveFactor(afterWarmup, (byte)input.AfterstartCorrectionC5, 3);

        ushort afterAdditions = AddFuelFinalStack(
            afterAfterstart,
            (ushort)input.TransientFuelAdd2055,
            (ushort)input.TransientFuelAdd2057,
            (ushort)input.SlowCorrection2590,
            (ushort)input.SubtractiveFilter2584
        );

        ushort afterPeriodLimit = Math.Min(afterAdditions, axes.EnginePeriodTicks);
        ushort afterMultiplier = FixedPoint.ApplyFuelMultiplier2053(afterPeriodLimit, (byte)input.FuelMultiplier2053);
        if (afterMultiplier > 32_000)
        {
            afterMultiplier = 32_000;
        }

        ushort corrected2051 = afterMultiplier;
        ushort afterLambda = input.FastLambdaFuelCorrection2049 == 0
            ? afterMultiplier
            : FixedPoint.ApplyScaledPositiveFactor(afterMultiplier, (byte)input.FastLambdaFuelCorrection2049, 2);
        if (afterLambda > 32_000)
        {
            afterLambda = 32_000;
        }
        afterLambda = Math.Min(afterLambda, axes.EnginePeriodTicks);

        ushort beforeHighLoad = afterLambda;
        byte highLoadRaw = 0;
        ushort final = beforeHighLoad;

        if (input.ApplyStatelessHighLoadDurationSupport)
        {
            warnings.Add(
                "The optional 0x6E96 high-load duration stage is evaluated statelessly. The real firmware carries A1.40 hysteresis/history across calls."
            );

            bool stateEnabled = (input.StateFlagsA3 & 0x80) != 0;
            bool activate = stateEnabled && ((ushort)input.FuelEventWidthLimitBF >> 1) > beforeHighLoad;
            if (activate)
            {
                ushort highLoadXAxis = BuildHighLoadXAxis(axes.LoadAxisQ8_8);
                highLoadRaw = RomLookup.Interp2DU8(
                    _rom,
                    0x85BA,
                    5,
                    5,
                    24,
                    highLoadXAxis,
                    axes.RpmAxisQ8_8,
                    out LookupTrace highLoadTrace,
                    "High-load fuel-duration support 0x85BA"
                );
                traces.Add(highLoadTrace);
                final = unchecked((ushort)(beforeHighLoad + (highLoadRaw << 1)));
            }
        }

        warnings.Add(
            "Fuel mode from-intermediates reproduces the decoded static E927/E5E8/E652 arithmetic, but the supplied RAM terms still come from state machines not reconstructed from physical inputs. It does not model the operating-state-12 helper at 0x96F3."
        );

        return new FuelResult
        {
            Mode = mode,
            SelectedTrimTable = trimName,
            SelectedTrimAddress = trimAddress,
            IatRpmCorrectionARaw = correctionA,
            IatRpmCorrectionBRaw = correctionB,
            SignedQuantityTrimRaw = trim,
            SignedQuantityTrimPercent = trim * 100.0 / 256.0,
            InputBasePulseRaw = (ushort)input.BaseFuelPulseRaw,
            SummedFuelCorrection204B = sum204B,
            SummedFuelCorrection204BSigned = sum204BSigned,
            FuelBlendWord204E = blend204E,
            BaseBeforeBlendRaw = baseBeforeBlend,
            BaseAfterBlendRaw = baseAfterBlend,
            AfterSignedTrimRaw = afterTrim,
            AfterAdaptiveTrimRaw = afterAdaptive,
            AfterWarmupRaw = afterWarmup,
            AfterAfterstartRaw = afterAfterstart,
            AfterTransientStackRaw = afterAdditions,
            AfterPeriodLimitRaw = afterPeriodLimit,
            AfterFuelMultiplierRaw = afterMultiplier,
            CorrectedFuelCharge2051Raw = corrected2051,
            AfterFastLambdaRaw = afterLambda,
            BeforeHighLoadSupportRaw = beforeHighLoad,
            HighLoadSupportTableRaw = highLoadRaw,
            FinalDurationRaw = final,
            FinalDurationMilliseconds = ToMilliseconds(final)
        };
    }

    private (sbyte Value, int Address, string Name) SelectFuelTrim(
        CalculationInputs input,
        ResolvedAxes axes,
        List<LookupTrace> traces)
    {
        int address = ResolveFuelTrimAddress(input, axes.RpmAxisQ8_8);
        if (address == 0x83F0)
        {
            sbyte value = RomLookup.Interp1DS8(
                _rom,
                0x83F0,
                24,
                axes.RpmAxisQ8_8,
                out LookupTrace trace,
                "RPM-only signed fuel trim 0x83F0"
            );
            traces.Add(trace);
            return (value, 0x83F0, "RPM-only signed fuel trim 0x83F0");
        }

        bool lowRpm = address is 0x81F8 or 0x82F4;
        string name = lowRpm
            ? (address == 0x81F8 ? "Low-RPM fuel trim A 0x81F8" : "Low-RPM fuel trim B 0x82F4")
            : (address == 0x821C ? "Fuel quantity trim A 0x821C" : "Fuel quantity trim B 0x8318");

        sbyte result = RomLookup.Interp2DS8(
            _rom,
            address,
            9,
            9,
            lowRpm ? 4 : 24,
            axes.LoadAxisQ8_8,
            axes.RpmAxisQ8_8,
            out LookupTrace lookup,
            name
        );
        traces.Add(lookup);
        return (result, address, name);
    }

    internal static int ResolveFuelTrimAddress(CalculationInputs input, ushort rpmAxis)
    {
        if ((input.OperatingModeFlagsA9 & 0x20) != 0)
        {
            return 0x83F0;
        }

        bool bankA = input.BankSelector20B1 != 0;
        bool lowRpm = rpmAxis <= 0x0300
            && (input.OperatingModeFlagsA9 & 0x40) != 0
            && input.LowRpmFuelTrimGuardsSatisfied;
        return lowRpm
            ? (bankA ? 0x81F8 : 0x82F4)
            : (bankA ? 0x821C : 0x8318);
    }

    private ushort CalculateSummedFuelCorrection(CalculationInputs input, sbyte correctionA)
    {
        ushort d = SignExtendToWord(correctionA);
        d = unchecked((ushort)(d + WrapWord(input.Adaptive2596)));
        d = unchecked((ushort)(d + SignExtendToWord((sbyte)input.SignedFuelCorrection2050)));
        d = unchecked((ushort)(d << 1));

        if (input.BankSelector20B1 == 0)
        {
            ushort extra = SignExtendToWord((sbyte)input.Signed2610);
            if ((input.OperatingModeFlagsA9 & 0x40) != 0)
            {
                extra = unchecked((ushort)(extra << 1));
            }
            d = unchecked((ushort)(d + extra));
        }

        d = unchecked((ushort)(d + WrapWord(input.Correction24D9)));
        return d;
    }

    private ushort CalculateFuelBlend(CalculationInputs input, sbyte correctionB)
    {
        ushort d = SignExtendToWord(correctionB);
        d = unchecked((ushort)(d + WrapWord(input.Ram0006)));
        d = unchecked((ushort)(d + _rom.ReadUInt16BigEndian(0x8028)));
        return unchecked((short)d) < 0 ? (ushort)0 : d;
    }

    private static ushort AddSignedAndClampNonnegative(ushort unsignedBase, ushort signedAddition)
    {
        ushort result = unchecked((ushort)(unsignedBase + signedAddition));
        return unchecked((short)result) < 0 ? (ushort)0 : result;
    }

    private static ushort AddFuelFinalStack(
        ushort value,
        ushort addA,
        ushort addB,
        ushort slowAdd,
        ushort subtract)
    {
        uint current = value;
        current += addA;
        if (current > 65_535u) return 32_000;
        current += addB;
        if (current > 65_535u) return 32_000;
        current += slowAdd;
        if (current > 65_535u) return 32_000;

        if (current < subtract)
        {
            return 0;
        }

        current -= subtract;
        return (ushort)Math.Min(current, 32_000u);
    }

    private static ushort BuildHighLoadXAxis(ushort loadAxis)
    {
        byte high = (byte)(loadAxis >> 8);
        byte low = (byte)loadAxis;
        high = unchecked((byte)(high - 1));
        ushort adjusted = (ushort)((high << 8) | low);
        ushort doubled = unchecked((ushort)(adjusted << 1));
        return (doubled >> 8) >= 4 ? (ushort)0x0400 : doubled;
    }

    private ushort RpmToPeriod(int rpm)
    {
        int period = checked((int)Math.Round(
            _assumptions.RpmClockNumerator / (double)rpm,
            MidpointRounding.AwayFromZero
        ));
        return (ushort)Math.Clamp(period, 1, 65_535);
    }

    private double? ToMilliseconds(ushort raw)
    {
        return _assumptions.TimerTickMicroseconds is null
            ? null
            : raw * _assumptions.TimerTickMicroseconds.Value / 1_000.0;
    }

    private static ushort SignExtendToWord(sbyte value) => unchecked((ushort)(short)value);

    private static ushort WrapWord(int value) => unchecked((ushort)value);

}
