#!/bin/bash
#Variables
APT_SOURCE='/websites/myscript/'
BROTLINWANT='Y'
PAGESPEEDWANT='Y'
HEADERSMOREWANT='Y'
PWDIR=$(pwd)
echo "This will compile custom nginx with BROTLI / PAGESPEED / HEADERS MORE / GEO IP"
echo "Select following modules"
read -r -p "Do want to install Geo IP NGINX Module? [Y/n] " GEOIPWANT
case $GEOIPWANT in
		[yY])
	  GEOIPWANT='Y'
	  ;;
	  *)
	  GEOIPWANT='n'
	  ;;
esac
read -r -p "Do want to install BROTLI Nginx Module? [Y/n] " BROTLINWANT
case $BROTLINWANT in
		[yY])
	  BROTLINWANT='Y'
	  ;;
	  *)
	  BROTLINWANT='n'
	  ;;
esac
read -r -p "Do want to install More Headers Nginx Module? [Y/n] " HEADERSMOREWANT
case $HEADERSMOREWANT in
		[yY])
	  HEADERSMOREWANT='Y'
	  ;;
	  *)
	  HEADERSMOREWANT='n'
	  ;;
esac
read -r -p "Do want to install Google Page Speed Nginx Module? [Y/n] " PAGESPEEDWANT
case $PAGESPEEDWANT in
		[yY])
	  PAGESPEEDWANT='Y'
	  ;;
	  *)
	  PAGESPEEDWANT='n'
	  ;;
esac




echo "Creating NGINX SOURCE"
echo "#### nginx ####" >> $APT_SOURCE/nginx.list
echo "deb http://nginx.org/packages/ubuntu/ $(lsb_release -c -s) nginx" >> $APT_SOURCE/nginx.list
echo "deb-src http://nginx.org/packages/ubuntu/ $(lsb_release -c -s) nginx" >> $APT_SOURCE/nginx.list
#curl -L https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
#echo "Creating PHP SOURCE"
#echo "### PHP Source ###" >> $APT_SOURCE/php.list
#echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu $(lsb_release -c -s) main" >> $APT_SOURCE/php.list

if [ "$GEOIPWANT" == "Y" ]; then
echo "Creating MaxMind SOURCE"
echo "#### MaxMind ####" >> $APT_SOURCE/maxmind.list
echo "deb http://ppa.launchpad.net/maxmind/ppa/ubuntu $(lsb_release -c -s) main" >> $APT_SOURCE/maxmind.list
echo "#deb-src http://ppa.launchpad.net/maxmind/ppa/ubuntu $(lsb_release -c -s) main" >> $APT_SOURCE/maxmind.list
fi
echo "Refreshing packages..."
#sudo apt update
echo "Installing required packages...."
#sudo apt install -y uuid-dev dpkg-dev build-essential zlib1g-dev libpcre3 libpcre3-dev unzip git passenger libmaxminddb0 libmaxminddb-dev mmdb-bin libgeoip-dev
echo "Please enter directory where you want to build custom nginx.  Default is (/usr/local/src):"
read CBDIR
if [ "$CBDIR" == "" ]; then
	CBDIR='/usr/local/src'
	CBDIR="/websites/myscript/src"
fi
echo "Installing source and required files in $CBDIR"
mkdir -p $CBDIR
cd $CBDIR
sudo apt source nginx
echo "Installing required files for building...."
#apt build-dep nginx -y
if [ "$BROTLINWANT" == "Y" ]; then
echo "Downloading BROTLIN module...."
git clone --recursive https://github.com/eustas/ngx_brotli.git >/dev/null 2>&1
fi
if [ "$GEOIPWANT" == "Y" ]; then
echo "Downloading GeoIP Module...."
git clone https://github.com/leev/ngx_http_geoip2_module.git >/dev/null 2>&1
fi
if [ "$HEADERSMOREWANT" == "Y" ]; then
echo "Downloading Headers More Module...."
git clone https://github.com/openresty/headers-more-nginx-module.git >/dev/null 2>&1
fi
if [ "$PAGESPEEDWANT" == "Y" ]; then
echo "Downloading Page Speed Modules...."
wget -q https://github.com/apache/incubator-pagespeed-ngx/archive/v1.13.35.2-stable.tar.gz >/dev/null
wget -q https://www.modpagespeed.com/release_archive/1.13.35.2/psol-1.13.35.2-x64.tar.gz >/dev/null
echo "Extracting files....."
tar xpf psol-1.13.35.2-x64.tar.gz >/dev/null
tar xvzf v1.13.35.2-stable.tar.gz >/dev/null
mv incubator-pagespeed-ngx-1.13.35.2-stable pagespeed-ngx-1.13.35.2-stable
mv psol pagespeed-ngx-1.13.35.2-stable
echo "Cleaning up....."
rm psol-1.13.35.2-x64.tar.gz v1.13.35.2-stable.tar.gz
fi
echo "Getting NGINX folder..."
NGINXSOURCE=$(find . -maxdepth 1 -name \*nginx-1\* -type d  -print | head -n1)
echo "$CBDIR/$NGINXSOURCE"
PAGESPEEDCONFIG=" --add-module=$CBDIR/pagespeed-ngx-1.13.35.2-stable "
BROTLINCONFIG=" --add-module=$CBDIR/ngx_brotli "
HEADERSCONFIG=" --add-module=$CBDIR/headers-more-nginx-module "
echo $PAGESPEEDCONFIG
echo "Adding additional modules to compile..."
sudo sed -i "s#--with-cc-opt#$PAGESPEEDCONFIG --with-cc-opt#g" $CBDIR/$NGINXSOURCE/debian/rules
sudo sed -i "s#--with-cc-opt#$BROTLINCONFIG --with-cc-opt#g" $CBDIR/$NGINXSOURCE/debian/rules
sudo sed -i "s#--with-cc-opt#$HEADERSCONFIG --with-cc-opt#g" $CBDIR/$NGINXSOURCE/debian/rules
echo "Compiling...."
cd "$CBDIR/$NGINXSOURCE"
sudo dpkg-buildpackage -b -uc -us


