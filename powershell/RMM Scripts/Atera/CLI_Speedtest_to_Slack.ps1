#Created by Michael Stants - June 1 2021

##############################
# Variables you need to set  #
##############################

# Slack Webhook URL
$Webhook = "WEBHOOK URL HERE"

# Working Directory (with a trailing \)
$WorkingDir = "C:\System\"

# Don't modify anything below here. 

# Get system hostname

$hostname = $env:computername

# Check for working directory and create it if there isn't one. 
$path = $WorkingDir
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
      Write-Host "Created working directory."
} ELSE {
      Write-Host "Working Directory exists already. Moving on."
}

# Check for speedtest in $WorkingDir
$speedtestPath = $WorkingDir + "speedtest\speedtest.exe"
$SpeedtestExecutable = Test-Path -Path $speedtestPath

# If the speedtest.exe exists, lets not download it again.
If ($SpeedtestExecutable){
Write-Host "Speedtest application exists - Moving on"
} ELSE {
Write-Host "Downloading Speedtest"
# Setting up the directory
$SpeedtestDestinationPath = $WorkingDir + "speedtest"
$ZipPath = $WorkingDir + "speedtest.zip"

# Download the speedtest cli from speedtest.net
Invoke-WebRequest -UseBasicParsing -Uri "https://install.speedtest.net/app/cli/ookla-speedtest-1.0.0-win64.zip" -OutFile $ZipPath

# Unpack the archive
Expand-Archive $ZipPath -DestinationPath $SpeedtestDestinationPath -Force

# Cleanup your mess
Remove-Item $ZipPath
}

Write-Host "Running Speedtest"

#Run the speedtest and then get the results URL - Append .png to this to display the image in slack. 
$speedtestobj = powershell $speedtestPath --accept-license --format=json --progress=no | ConvertFrom-Json
$speedtestResultImage = $speedtestobj.result.url + ".png"

# Prep the slack message
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

# Set TLS for older machines (Fixes an issue with TLS 1.0 being default on Server 2012 R2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Slack me baby!
Invoke-RestMethod -uri $Webhook -Method Post -body $slackPayload -ContentType $ContentType
