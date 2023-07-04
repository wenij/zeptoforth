\ Copyright (c) 2023 Travis Bemann
\
\ Permission is hereby granted, free of charge, to any person obtaining a copy
\ of this software and associated documentation files (the "Software"), to deal
\ in the Software without restriction, including without limitation the rights
\ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
\ copies of the Software, and to permit persons to whom the Software is
\ furnished to do so, subject to the following conditions:
\ 
\ The above copyright notice and this permission notice shall be included in
\ all copies or substantial portions of the Software.
\ 
\ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
\ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
\ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
\ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
\ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
\ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
\ SOFTWARE.

begin-module net-test
  
  oo import
  cyw43-control import
  net-misc import
  frame-process import
  net import
  net-diagnostic import
  endpoint-process import
  
  23 constant pwr-pin
  24 constant dio-pin
  25 constant cs-pin
  29 constant clk-pin
  
  0 constant pio-addr
  0 constant sm-index
  pio::PIO0 constant pio-instance
  
  <cyw43-control> class-size buffer: my-cyw43-control
  <interface> class-size buffer: my-interface
  <frame-process> class-size buffer: my-frame-process
  <arp-diag-handler> class-size buffer: my-arp-diag-handler
  <ipv4-diag-handler> class-size buffer: my-ipv4-diag-handler
  <arp-handler> class-size buffer: my-arp-handler
  <ip-handler> class-size buffer: my-ip-handler
  <endpoint-process> class-size buffer: my-endpoint-process
  
  \ Our port
  4444 constant my-port
  
  <endpoint-handler> begin-class <udp-echo-handler>
    
  end-class

  <udp-echo-handler> begin-implement
  
    \ Handle a endpoint packet
    :noname { endpoint self -- }
      endpoint rx-ipv4-source@ { src-addr src-port }
      endpoint rx-packet@ { addr bytes }
      cr ." SOURCE: " src-addr ipv4. space src-port .
      addr addr bytes + dump
      addr bytes my-port src-addr src-port bytes [: { addr bytes buf }
        addr buf bytes move true
      ;] my-interface send-ipv4-udp-packet drop
    ; define handle-endpoint
  
  end-implement
  
  <udp-echo-handler> class-size buffer: my-udp-echo-handler
  variable my-endpoint
  
  : init-test ( -- )
    dma-pool::init-dma-pool
    cyw43-clm::data cyw43-clm::size cyw43-fw::data cyw43-fw::size
    pwr-pin clk-pin dio-pin cs-pin pio-addr sm-index pio-instance
    <cyw43-control> my-cyw43-control init-object
    my-cyw43-control init-cyw43
    my-cyw43-control cyw43-frame-interface@ <interface> my-interface init-object
    192 168 1 44 make-ipv4-addr my-interface intf-ipv4-addr!
    255 255 255 0 make-ipv4-addr my-interface intf-ipv4-netmask!
    my-cyw43-control cyw43-frame-interface@ <frame-process> my-frame-process init-object
    <arp-diag-handler> my-arp-diag-handler init-object
    <ipv4-diag-handler> my-ipv4-diag-handler init-object
    my-interface <arp-handler> my-arp-handler init-object
    my-interface <ip-handler> my-ip-handler init-object
    my-arp-diag-handler my-frame-process add-frame-handler
    my-ipv4-diag-handler my-frame-process add-frame-handler
    my-arp-handler my-frame-process add-frame-handler
    my-ip-handler my-frame-process add-frame-handler
    my-interface <endpoint-process> my-endpoint-process init-object
    <udp-echo-handler> my-udp-echo-handler init-object
    my-udp-echo-handler my-endpoint-process add-endpoint-handler
    my-interface allocate-endpoint drop my-endpoint !
    my-port my-endpoint @ listen-udp
  ;

  : run-test { D: ssid D: pass -- }
    init-test
    begin ssid pass my-cyw43-control join-cyw43-wpa2 nip until
    my-endpoint-process run-endpoint-process
    my-frame-process run-frame-process
  ;

end-module