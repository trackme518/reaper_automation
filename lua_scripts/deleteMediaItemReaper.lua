-- vojtech leischner 2024 - tested with Reaper 7.09
-- delete media item on given track with given name
--parameters for the script are derived from first track name which is beforehand set with OSC call

-- docs:
--https://www.reaper.fm/sdk/reascript/reascripthelp.html#GetMediaItem

--get first track
tr = reaper.GetTrack(0, 0);
--GetTrackName used as path parameter - first number of Track where we should search, second the name of the media file to delete
-- example:
-- 2;test.wav 
-- will delete media item with name "test.wav" on track 2
-- you can check the take name by right-click -> item properties -> Take name:

-- store parameters in trName
retval, trName = reaper.GetTrackName(tr)

-- Lua does not have a split command - example how to get strings with separators / delimeters - not used in code
it = 0
--mediaName = "fdgrz"
trackNumber = 0 --where to search
mediaName = "" --name of the file we want to delete
for i in string.gmatch(trName,"([^;]+)") do
--    print(i)
    if it == 0 then
    trackNumber = tonumber(i)-1
    end
    if it == 1 then
    mediaName = i
    end
    it = it +1 
 end

--select track
SelTrack = reaper.GetTrack( 0, trackNumber )
--count how many media items are on given track
CountTrItem = reaper.CountTrackMediaItems( SelTrack )
--iterate over all media on given track
    if CountTrItem > 0 then
        for i = 1,CountTrItem do
            --get media item pointer
            Tr_item =  reaper.GetTrackMediaItem( SelTrack, i-1 )
            --get take (media item instance)
            Take = reaper.GetActiveTake( Tr_item )
            --check we actually have something
            if Take ~= nil then
              --get take name
              Take_Name = reaper.GetTakeName( Take )
              --if take name equals what we want to delete
              if Take_Name == mediaName then
                  --delete the media item
                  reaper.DeleteTrackMediaItem(SelTrack, Tr_item)
                  break -- escape the for loop
              end
            end       
        end
    end 