#!/bin/bash

echo "Welcome to the releaser! " ;

echo "--------------------------------- " ;

RELEASEENV=$1;

case $RELEASEENV in
	stage) echo "Environment: $RELEASEENV" ;;
	production) echo "Environment: $RELEASEENV" ;;	
	*) echo "Release environment not available"; exit ;;
esac

echo "--------------------------------- " ;

# override
RELEASES=/data/www/${RELEASEENV}.findyourperfectvenue.com/releases;
RELEASEVERSIONFILE=/data/scripts/${RELEASEENV}_release_version;


if [ ! -d "$RELEASES" ]; then
    mkdir -p $RELEASES;
fi

if [ ! -f "$RELEASEVERSIONFILE" ]; then
	touch RELEASEVERSIONFILE ;
fi

RELEASEVER=`cat ${RELEASEENV}_release_version` ;

RELEASEVER=$((RELEASEVER+1));

echo "RELEASE VERSION : $RELEASEVER" ;

RELEASE_LOG=${RELEASEENV}_release_version;

echo $RELEASEVER > $RELEASE_LOG ;

cd $RELEASES;

# release

TODAY=$(date +"%d-%m-%Y") ;

echo "Date : $TODAY" ;

RELEASENAME=release_${TODAY}_${RELEASEVER} ;

echo "Release name - $RELEASENAME" ;

mkdir $RELEASENAME && cd $RELEASENAME ;

echo "Cloning git repo.. \n " ;

git clone git@github.com:matzhouse/findyourperfectvenue.com.git . && git checkout stage ;

# Run php composer to get all the shiz
php composer.phar install ;

cd /data/www/${RELEASEENV}.findyourperfectvenue.com ;

echo "Linking new release to - $RELEASENAME";

SYMLINK=/data/www/${RELEASEENV}.findyourperfectvenue.com/public_html ;

SYMLINKTEMP=${SYMLINK}_temp ;

TARGET=${RELEASES}/${RELEASENAME} ;
 

if [[ -h "$SYMLINK" ]]; then
  # It already exist, use mv to change the target path atomically.
  ln -s "$TARGET" "$SYMLINKTEMP" ;
  mv -f -T "$SYMLINKTEMP" "$SYMLINK" ;
else
  # It doesn't exist set, just a simple creation.
  ln -s "$TARGET" "$SYMLINK"
fi

# ln -s -f $STAGERELEASES/$RELEASENAME ./public_html ;

echo "DONE!" ;
