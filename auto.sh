#!/bin/sh

echo "★ clear testfiles"
rm ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.* > /dev/null

echo "★ test alice incrypting a message to bob (PU and Sonic PNG) with bob private key"
swift run dhdigest \
    -i ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png \
    -o ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.enc \
    -m enc \
    -f $(./.build/debug/dhdigest -m show -b -l bob) \
    -l alice
[ $? != 0 ] && exit 1

echo "make sure they are different"
diff ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png \
     ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.enc
[ $? != 1 ] && echo "file is not different, not encrypted" && exit 1

echo "★ decrypt the message with bob private key"
swift run dhdigest \
    -i ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.enc \
    -o ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.enc.png \
    -m dec \
    -f $(./.build/debug/dhdigest -m show -b -l alice) \
    -l bob
[ $? != 0 ] && exit 1

echo "make sure they match"
diff ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png \
     ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.enc.png
    
echo "clean up"
rm ./Tests/DiffieHellmanSecurityTests/Mocks/PUandSonic.png.* > /dev/null
