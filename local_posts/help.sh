# 网页上博客需要的图片路径和本地不同，所以写了个脚本
# 文件名带local的，是在本地读的，不带的，方便在网页上看
# local的提交不显示
path=$1
echo "path: "$path
file=$(basename $path)
md-toc --insert $file
echo "generate md-toc success!"
filename=$(basename $path -local.md)
echo "old filename: "$filename
newfile=$filename".md"
echo "newfile: "$newfile
rm -f ../_posts/$newfile
sed 's#../images#/images#g' $file >> ../_posts/$newfile
echo "generate web blog file success!"