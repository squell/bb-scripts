grep -l 'There are no student comments for this assignment' *.txt | sed 's/^/rm "/;s/$/";/' > clean_this.sh ;
chmod 744 clean_this.sh ;
./clean_this.sh ;
rm clean_this.sh
echo "cleaned useless txt files!"