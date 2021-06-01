#Created by Michael Stants - June 1 2021

##############################
# Variables you need to set  #
##############################

# Slack Webhook URL
$Webhook = "WEBHOOK URL HERE"

# Working Directory (with a trailing \)
$WorkingDir = "C:\System\"

# Get system hostname

$hostname = $env:computername

# Check for System Folder in C:\ and create it if there isn't one. 
$path = $WorkingDir
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
      Write-Host "Created system folder for installers"
} ELSE {
      Write-Host "System Folder exists already."
}

# Check for speedtest in $WorkingDir
$speedtestPath = $WorkingDir + "speedtest\speedtest.exe"
$SpeedtestExecutable = Test-Path -Path $speedtestPath

If ($SpeedtestExecutable){
Write-Host "Speedtest application exists - Skipping download"
} ELSE {
Write-Host "Downloading Speedtest"
$SpeedtestDestinationPath = $WorkingDir + "speedtest"
$ZipPath = $WorkingDir + "speedtest.zip"
Invoke-WebRequest -UseBasicParsing -Uri "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip" -OutFile $ZipPath
Expand-Archive $ZipPath -DestinationPath $SpeedtestDestinationPath -Force
Remove-Item $ZipPath
}
Write-Host "Running Speedtest"

$speedtestobj = powershell $speedtestPath --accept-license --format=json --progress=no | ConvertFrom-Json

$speedtestResultImage = $speedtestobj.result.url + ".png"

Write-Host "Sending to Results to Slack"


$ContentType= 'application/json'
$slackPayload = @"
    {
	"blocks": [
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "A speedtest was run on *$hostname*"
			}
		},
		{
			"type": "image",
			"title": {
				"type": "plain_text",
				"text": "Result:",
				"emoji": true
			},
			"image_url": "$speedtestResultImage",
			"alt_text": "Speedtest Results"
		}
	]
    }
"@
Invoke-RestMethod -uri $Webhook -Method Post -body $slackPayload -ContentType $ContentType
