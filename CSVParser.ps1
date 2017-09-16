param(
[string]$csvfilename,
[string]$datafilename
)
$file = Import-CSV C:\Users\Student\Downloads\Mft2Csv-master\Mft2Csv-master\$csvfilename

$filepaths = @()
$filenames = @()
$sitimestamp = @()
$fntimestamp = @()
$timestomped = @()
$file | ForEach_Object{

#File paths and File Names
if ($_.SourceType -eq "FILE"){
$filepaths += $_.Desc
$filenames += $_.filename
#$SI timestamps 
if($_.Short -eq "SI"){
$sitimestamp += $_.Time
}
#$FN timestamps
if($_.Short -like "FN*"){
$fntimestamp += $_.Time
}

}
#Identifying potential time stomp entries
#Get filename portion of file path
$path = $_.Desc
$parts = $path -split '/'
#If filename does not match the file path piece
#it may be timestomped
if($_.filename -ne $parts[-1]){
$timestomped += $path
}

}