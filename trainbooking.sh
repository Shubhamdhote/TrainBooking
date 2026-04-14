#!/bin/bash

BASEDIR='/home/shubh'

DATADIR=${BASEDIR}/data
FILE=${DATADIR}/trainbooking.txt

echo "$FILE"

select OPTION in "View Train Details and Check Availability" "Book Ticket" "Cancel Ticket" "Exit"
do
case $OPTION in

"View Train Details and Check Availability")
        echo "Checking train availability"

        awk 'BEGIN{FS=":"; OFS="\t"; print "SOURCE","DESTINATION"; print "------","-----------"} {print $2,$3}' "$FILE"

        read -p "Source? " SRC
        read -p "Destination? " DEST

        RESULT=$(grep -i ":${SRC}:${DEST}:" "$FILE")

        if [ -z "$RESULT" ]
        then
                echo "❌ No train found"
        else
                echo "✅ Train Details:"
                echo "$RESULT"
        fi
        ;;

"Book Ticket")
        echo "Book Ticket"

        awk 'BEGIN{FS=":"; OFS="\t"; print "SOURCE","DESTINATION"; print "------","-----------"} {print $2,$3}' "$FILE"

        read -p "Source? " SRC
        read -p "Destination? " DEST

        RESULT=$(grep -i ":${SRC}:${DEST}:" "$FILE" | head -1)

        if [ -z "$RESULT" ]
        then
                echo "❌ No train found"
                continue
        fi

        echo "✅ Train Details:"
        echo "$RESULT"

        LINENUM=$(grep -in ":${SRC}:${DEST}:" "$FILE" | head -1 | cut -d":" -f1)

        TOTTKT=$(echo "$RESULT" | awk -F ":" '{print $4}')

        read -p "Ticket Count? " REQTKT

        # VALIDATION
        if ! [[ "$REQTKT" =~ ^[0-9]+$ ]]
        then
                echo "❌ Invalid number"
                continue
        fi

        if ! [[ "$TOTTKT" =~ ^[0-9]+$ ]]
        then
                echo "❌ Data error in file"
                continue
        fi

        if [ "$REQTKT" -le 0 ]
        then
                echo "❌ Ticket must be greater than 0"
                continue
        fi

        if [ "$REQTKT" -gt "$TOTTKT" ]
        then
                echo "❌ Not enough tickets available"
                continue
        fi

        NEWTKT=$((TOTTKT - REQTKT))

        sed -i "${LINENUM}s/^\([^:]*:[^:]*:[^:]*:\)$TOTTKT/\1$NEWTKT/" "$FILE"

        echo "✅ Booking Successful!"
        echo "Remaining Tickets: $NEWTKT"
        ;;

"Cancel Ticket")
        echo "Cancel Ticket"

        read -p "Source? " SRC
        read -p "Destination? " DEST
        read -p "Cancel Tickets? " CTKT

        RESULT=$(grep -i ":${SRC}:${DEST}:" "$FILE" | head -1)

        if [ -z "$RESULT" ]
        then
                echo "❌ No train found"
                continue
        fi

        LINENUM=$(grep -in ":${SRC}:${DEST}:" "$FILE" | head -1 | cut -d":" -f1)

        TOTTKT=$(echo "$RESULT" | awk -F ":" '{print $4}')

        if ! [[ "$CTKT" =~ ^[0-9]+$ ]]
        then
                echo "❌ Invalid number"
                continue
        fi

        NEWTKT=$((TOTTKT + CTKT))

        sed -i "${LINENUM}s/^\([^:]*:[^:]*:[^:]*:\)$TOTTKT/\1$NEWTKT/" "$FILE"

        echo "✅ Ticket Cancelled Successfully"
        echo "Updated Tickets: $NEWTKT"
        ;;

"Exit")
        exit
        ;;

*)
        echo "Invalid option"
        ;;
esac
done
