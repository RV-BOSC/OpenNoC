
write status 1110000 addr+rn0+rn1
             1110001 addr+hnf
write data   1110010 addr
             1110011 hnf
             1110100 sni

read status  1110101 addr+rn0+rn1
             1110110 addr+hnf
read data    1110111 addr
             1111000 hnf
             1111001 sni
end signal   1111111

hnf_channels_NAME    source_NAME    hnf_channels_ID    source_ID    packet_ID
  
      rxreq              rn0              000              00           00
                                       
                         rn1              000              01           00
                                       
      rxrsp              rn0              001              00           00
                                                        
                         rn1              001              01           00
                                                        
                         sni              001              10           00
                                                        
      rxdat              rn0              010              00           00
                                          010              00           01
                                                        
                         rn1              010              01           00
                                          010              01           01
                                                         
                         sni              010              10           00
                                          010              10           01
    
hnf_channels_NAME    target_NAME    hnf_channels_ID    target_ID    packet_ID

      txreq              sni              011              10           00
                                                        
      txrsp              rn0              100              00           00
                                                        
                         rn1              100              01           00
                                                        
                         sni              100              10           00
                                                        
      txdat              rn0              101              00           00
                                          101              00           01
                                                        
                         rn1              101              01           00
                                          101              01           01
                                                        
                         sni              101              10           00
                                          101              10           01
                                                        
      txsnp              rn0              110              00           00
                                                        
                         rn1              110              01           00

source_NAME          target_NAME       flit_NAME        flit_TYPE

     sni                 rn0           DBIDResp          1111100

     rn0                 sni           NCBWrDat0         1111101
                                       NCBWrDat1         1111110
             
     sni                 rn0           CompData0         1111010
                                       CompData1         1111011