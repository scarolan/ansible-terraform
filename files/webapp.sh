#!/bin/sh

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body style="background-image: linear-gradient(red,orange,yellow,green,blue,indigo,violet);">
  <center><img src="http://placekitten.com/800/600"></img></center>
  <marquee><h1>Meow World</h1></marquee>
  </body>
</html>
EOM

echo "Your demo is now ready."
