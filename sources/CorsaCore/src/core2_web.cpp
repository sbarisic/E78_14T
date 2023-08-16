
#include <core2.h>

#include <esp_wifi.h>
#include <esp_netif.h>
#include <esp_sntp.h>
#include <esp_tls.h>

#include <lwip/sockets.h>
#include <lwip/netdb.h>
#include <lwip/dns.h>

#include <WiFi.h>
#include <HTTPClient.h>

void core2_http_get(const char *server_name)
{
    dprintf("HTTP GET %s\n", server_name);

    HTTPClient http;
    http.begin(server_name);
    http.addHeader("Content-Type", "text/plain");

    printf("GET returns %d\n", http.GET());
    String response = http.getString();

    printf("Response = %s\n", response.c_str());

    http.end();
}
