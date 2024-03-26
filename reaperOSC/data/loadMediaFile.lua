--get first track
tr = reaper.GetTrack(0, 0);

--GetTrackName used as path parameter - from where we should load new media track
retval, trName = reaper.GetTrackName(tr)
--cehck if specified file exists
exists = reaper.file_exists(trName)
if exists==false then
  return --if the file is not present exit
end

--getTrackVolume - used as parameter to which track we want to insert new media file
vol = reaper.GetMediaTrackInfo_Value(tr,"D_VOL") -- gets fader level 
voldb = 20*math.log(vol,10) -- converts fader to db
--retval, vol, pan =  reaper.GetTrackUIVolPan(tr) --alternative method

--create integer from the volume, ensure floor and make sure it is positive
sourceIndex = math.floor(math.abs(voldb-1.0))

--select track we want to hotswap - note that we are using volume of track 1 as parameter here
tr2 = reaper.GetTrack( 0, sourceIndex )
--select that track
--reaper.SetTrackSelected(tr2,true)
reaper.SetOnlyTrackSelected(tr2) --select track and deselect all other tracks

--countitems = reaper.CountTrackMediaItems(tr2)

--select first media item on that track
item = reaper.GetTrackMediaItem( tr2, 0 )
--if media exists delete that media item - make space for a new one
if item then
  reaper.DeleteTrackMediaItem(tr2,item)
end

--move edit cursor to start=0
reaper.ApplyNudge( 0, 1, 6, 0, 0, false, 0 )
--insert new media on current track
  reaper.InsertMedia(trName, 0)