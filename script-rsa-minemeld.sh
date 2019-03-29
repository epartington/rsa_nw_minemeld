#!/bin/bash
#script to pull minemeld feeed information list from

#sample crontab
# maltrail sinkhole domain downloads
# 22 3 * * * /root/rsa-minemeld/script-rsa-minemeld.sh


#name of the file in the feed file (feed.name)
feed_name="inboundfeedhcvalues"

#used for the columns of the csv
threat_name="minemeld"

#create the header line that will be added to the indicator file on line 1
csv_header="#indicator,#confidence,#share_level,#sources"

#location for tmp file processing
tmp_dir="/tmp"

#combined sinkhole indicator filename
output_file_name=$feed_name".csv"
tmp_filename=$feed_name".txt"

#webroot for SA feeds directory
#rsa_feed_webroot="/var/netwitness/srv/www/"
rsa_feed_webroot="/var/lib/netwitness/common/repo/"
# rsa_feed_webroot="/var/www/html/"

# sinkhole root webdirectory github
web_dl_link="https://192.168.254.23:9443/feeds/"$feed_name"?tr=1&v=csv&f=indicator&f=confidence&f=share_level&f=sources"

#sinkhole indicator download
# -k ignore cert validation
# -o save file to new name
cd $tmp_dir && curl -k -o $tmp_filename $web_dl_link 2> /dev/null
echo "Grabbed from link: "$web_dl_link

#write the initial file and first line
echo $csv_header > $output_file_name

#create the columns that will be used in the combined output file
csv_columns=","$threat_name","$feed_name

#strip control characters from end of line
sed -e 's/\r//g' $tmp_filename > $tmp_filename"2"

sed "s/$/$csv_columns/" $tmp_filename"2" > $output_file_name
#sed 's/^M//g' $output_file_name

echo "wrote out to "$output_file_name

#copy the output file to the RSA web directory for recurring feed to read from
cp $output_file_name $rsa_feed_webroot
echo $output_file_name" - copied to web root "$rsa_feed_webroot$output_file_name
echo "recurring feed to https://netwitness/nwrpmrepo/"$output_file_name
