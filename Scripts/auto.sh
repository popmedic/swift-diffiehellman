#!/bin/sh

echo "★ clear testfiles"
rm ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.* > /dev/null

echo "★ test alice incrypting a message to bob (PU and Sonic PNG) with bob private key"
swift run dhdigest \
    -i ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png \
    -o ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.enc \
    -m enc \
    -f $(./.build/debug/dhdigest -m show -b -l bob) \
    -l alice
[ $? != 0 ] && \
rm ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.* > /dev/null && \
exit 1

echo "make sure they are different"
diff ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png \
     ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.enc
[ $? != 1 ] && \
echo "file is not different, not encrypted" && \
rm ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.* > /dev/null && \
exit 1

echo "★ decrypt the message with bob private key"
swift run dhdigest \
    -i ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.enc \
    -o ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.enc.png \
    -m dec \
    -f $(./.build/debug/dhdigest -m show -b -l alice) \
    -l bob
[ $? != 0 ] && \
rm ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.* > /dev/null && \
exit 1

echo "make sure they match"
diff ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png \
     ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.enc.png
    
echo "clean up"
rm ./Tests/DiffieHellmanSecurityTests/TestData/PUandSonic.png.* > /dev/null
