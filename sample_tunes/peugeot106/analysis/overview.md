## ROM Overview

| Key | Label | Size | SHA256 | Checksum words | Pair sum | Byte sum 0x4000-0xFFFF | Valid checksum | Zero 0x0000-0x3FFF | Zero 0xB600-0xB7FF | Reset vector |
| --- | --- | ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| `peugeot_stock` | Peugeot stock M27C512_original | 65536 | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xFFFF` | `0xB59A` | yes | yes | yes | `0xB800` |
| `peugeot_stok` | Peugeot Stok folder duplicate | 65536 | `09E5D927BD6951ECF7B57F351CCD5D396DC95C191D12164F71671725B751A681` | `0x4A65/0xB59A` | `0xFFFF` | `0xB59A` | yes | yes | yes | `0xB800` |
| `peugeot_mod2` | Peugeot MOD2 | 65536 | `D3E4A451EDD236104C79190372FA1BE1E45AAD09398EABE6F7B7E1479D810855` | `0x47BE/0xB841` | `0xFFFF` | `0xB841` | yes | yes | yes | `0xB800` |
| `xantia_607c` | Citroen Xantia 1.6 8v IAW 8P.40 607C | 65536 | `05470171F86B8525F962F13370846E6D4A1A6FBABC0107D90E1497F88A5DFE89` | `0x9F83/0x607C` | `0xFFFF` | `0x607C` | yes | yes | yes | `0xB800` |
| `peug_106rally_org` | Peug.106Rally.org.bin public/tuned comparison | 65536 | `FE7D7953298C575BC08E4C301CE7E911BCE082D1515E1FCA68509A2C980E0141` | `0x4A65/0xB59A` | `0xFFFF` | `0xE160` | no | no | yes | `0xB800` |
| `rally13_ori` | RALLY13.ORI same-family comparison | 65536 | `5F4EF679F6D262502D0023CF9F441111BC5C694CD4E281394AD0FCBA810854CF` | `0x7A41/0x85BE` | `0xFFFF` | `0x85BE` | yes | yes | yes | `0xB800` |

