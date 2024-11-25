#!/bin/bash
articlesPerPage=2
blogpage=0
articleInd=$articlesPerPage

articleTot=0

for file in $(find src/blog -type f | sort -r); do 
	((articleTot++))
done
pagesTot=$(( ( articleTot + articlesPerPage - 1 ) / articlesPerPage ))
pagesNav="<section style=\"display:flex;position:relative;\"><div class=\"pagecount\">[ "
for (( page=1; page<=pagesTot; page++ )); do
	pagesNav="$pagesNav""&nbsp;<a href=\"blog_${page}.html\"> ${page} </a>&nbsp;"
done
pagesNav="$pagesNav"" ]</div><div class=\"treeview\"><a href=\"blogtree.html\">Tree view</a><div></section>"
#pagesNav="" #disable pages for now

echo "$pagesNav"

for file in $(find src/blog -type f | sort -r); do 
	if [ "$articleInd" -eq "$articlesPerPage" ]; then
		echo "$pagesNav" | sed -e "s/href=\"blog_${blogpage}.html\"//" >> blog_${blogpage}.html
		cat src/blog4 >> blog_${blogpage}.html
		((blogpage++))
		articleInd=0
		sed -e "/{{nav}}/r src/nav" -e "s/{{nav}}//" src/blog1 > blog_${blogpage}.html
		echo "$pagesNav" | sed -e "s/href=\"blog_${blogpage}.html\"//" >> blog_${blogpage}.html
	fi
	((articleInd++))
	filename="Article""$(basename $file)""_""$(head -n 1 $file | tr -c '[:alpha:]' '_')"".html"
	outpath="blog/article/""$filename"
	preproc="$file""p"
	title="$(head -n 1 $file)"

	sed "s|{{url}}|/$outpath|" $file | tail -n +2 > $preproc

	cat src/blog2 >> blog_${blogpage}.html
	cat $preproc >> blog_${blogpage}.html
	sed "s|{{url}}|/$outpath|" src/blog3 >> blog_${blogpage}.html

	sed -e "/{{ARTICLE}}/r $preproc" -e "s/{{ARTICLE}}//" -e "s/{{title}}/$title/" -e  "s|{{url}}|/$outpath|" -e "/{{nav}}/r src/nav" -e "s/{{nav}}//" src/blogpost > $outpath

	rm $preproc

	echo "wrote $file"
done

echo "$pagesNav" >> blog_${blogpage}.html
cat src/blog4 >> blog_${blogpage}.html

tree blog/article/ -H '.' -L 1 --noreport --hintro=/dev/null --houtro=/dev/null --dirsfirst --timefmt="%d-%b-%Y" --charset utf-7 --ignore-case -P "*.html" -i -r | head -n 6 | tail -n 5 | sed "s/&nbsp;//g" | sed "s/\.html</</" > src/filessrc.html
tree blog/article/ -H '.' -L 1 --noreport --hintro=/dev/null --houtro=/dev/null --dirsfirst --timefmt="%d-%b-%Y" --charset utf-7 --ignore-case -P "*.html" -i -r | sed "s/&nbsp;//g" | sed "s/\.html</</" > src/allfilessrc.html
sed -e "/{{PLACEHOLDER}}/r src/filessrc.html" -e "s/{{PLACEHOLDER}}//" -e "/{{nav}}/r src/nav" -e "s/{{nav}}//" src/indexsrc.html > index.html
sed -e "/{{PLACEHOLDER}}/r src/allfilessrc.html" -e "s/{{PLACEHOLDER}}//" -e "/{{nav}}/r src/nav" -e "s/{{nav}}//" src/treesrc.html > blogtree.html
