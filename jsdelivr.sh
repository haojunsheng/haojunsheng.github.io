path=$1
sed -i "_bak" 's#https://raw.githubusercontent.com/haojunsheng/ImageHost/master#https://cdn.jsdelivr.net/gh/haojunsheng/ImageHost#g' $path
rm $path"_bak"
echo "use jsdelivr as cdn success!"
