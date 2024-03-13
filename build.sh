#!/bin/bash
# This script is modified from https://github.com/ivan-hc/Chrome-appimage/raw/fe079615eb4a4960af6440fc5961a66c953b0e2d/chrome-builder.sh

APP=google-chrome
CHANNEL=${CHANNEL:-stable}  # "stable", "beta" or "dev"
VARIANT=${VARIANT:-stable}  # "stable", "beta" or "unstable"

mkdir ./${VARIANT}
cd ./${VARIANT}
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage -O appimagetool
chmod a+x ./appimagetool

wget "https://dl.google.com/linux/direct/google-chrome-${VARIANT}_current_amd64.deb"
ar x ./*.deb
tar xf ./data.tar.xz
mkdir $APP.AppDir
mv ./opt/google/chrome*/* ./$APP.AppDir/
mv ./usr/share/applications/*.desktop ./$APP.AppDir/
sed -i "s#/usr/bin/google-chrome#google-chrome#g" ./$APP.AppDir/*.desktop

if [ "$VARIANT" = "stable" ]; then
    cp ./$APP.AppDir/*logo_128*.png ./$APP.AppDir/$APP.png
else
    cp ./$APP.AppDir/*logo_128*.png ./$APP.AppDir/$APP-$VARIANT.png
    cd ./$APP.AppDir
    ln -sf google-chrome-$VARIANT google-chrome
    cd ..
fi

cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
APP=google-chrome
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
exec "${HERE}"/$APP "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun

echo "Create a tarball"
cd ./$APP.AppDir
tar cJvf ../$APP-${CHANNEL}-$VERSION-x86_64.tar.xz .
cd ..
mv ./$APP-${CHANNEL}-$VERSION-x86_64.tar.xz ..

echo "Create an AppImage"
ARCH=x86_64 ./appimagetool -n --verbose ./$APP.AppDir ../$APP-${CHANNEL}-$VERSION-x86_64.AppImage
cd ..
rm -rf ./${VARIANT}
