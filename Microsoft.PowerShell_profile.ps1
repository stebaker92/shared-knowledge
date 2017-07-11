# PATH
$env:Path += ";C:\Program Files\7-Zip"
$env:Path += ";C:\Ruby23\bin\"
$env:Path += ";E:\ngrok"
$env:Path += ";C:\program files\nodejs\"
$env:Path += ";E:\tools\"
$env:path += ";C:\Program Files (x86)\Microsoft SDKs\TypeScript\2.1\"
$env:path += ";" + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin"
$env:path += ";C:\Windows\System32\inetsrv"
$env:NODE_ENV = "development";

$webDeploy = (get-childitem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -last 1).GetValue("InstallPath")
$env:Path += (";" + $webDeploy)
	
	
# FUNCTIONS 
function npp($file) { & "C:\Program Files (x86)\Notepad++\notepad++.exe" $file}

#SQL
function deploy-motormart() {
	cd E:\MotorMart\Carfinance.MotorMart\
	msbuild /p:BuildProjectReferences=false .\Carfinance.Motormart.Schema\Carfinance.Motormart.Schema.sqlproj
	& "C:\Program Files (x86)\Microsoft SQL Server\130\DAC\bin\SqlPackage.exe" /Action:Publish `
	/SourceFile:Carfinance.MotorMart.Schema/bin/debug/Carfinance.MotorMart.Schema.dacpac `
	/TargetDatabaseName:MotorMartLocal `
	/TargetServerName:localhost `
	/p:BlockOnPossibleDataLoss=false
	
	# Replace the Live groupPhoneNumber to the DEV number #TODO use SSDT sqlcmd vars
	osql -d MotorMartLocal -Q "update intranetDepartments set groupPhoneNumber = '0161 xxx xxxx' where departmentId = 'IT'" -E 
}

#dotnet core

#publishes the Api in the current repo. will attempt to stop it first
function dotnetpublish($service) {
	$folder = getrepo
	
	$service = if ($service -eq $null) { $folder } else { $service }
	write-warning "Publishing $service"
	
	#stop the exe
	write-warning "Checking if process is running"
	$running = get-process -processname "${service}.Api" -ErrorAction SilentlyContinue
	if ($running) {
		write-warning "Attempting to stop process"
		Stop-Process -processname "${service}.Api"
	}
	
	write-warning "Calling dotnet publish"
	#publish to the _releases folder
	#msbuild Carfinance.ContactCentre.Api.xproj /p:target=Publish /p:DeployOnBuild=true /p:PublishDir="E:\MotorMart\_Releases\Test\" /p:Configuration=Debug /p:Platform="Any CPU"
	dotnet publish "src\${service}.Api" -o E:\MotorMart\_Releases\$service
	
	# Inject any secrets
	#$json = Get-Content -path "appKeys.json" -Raw | ConvertFrom-Json
	#$clientSecret = $json.sites.$service
		
	$appsettings = "E:\MotorMart\_Releases\$service\appsettings.json"
	$appsettingsdev = "E:\MotorMart\_Releases\$service\appsettings.development.json"
	# Replace any incorrect values 
	if ($appsettings | Test-Path) { (Get-Content $appsettings) | ForEach-Object {$_ -replace "=MotorMart;", "=MotorMartLocal;"} | Set-Content $appsettings }	
	
	#Ping the Api to wake it up
	$bindings = Get-IISSite $service | Select Bindings
	$url = $bindings.Bindings.protocol + "://" + $bindings.Bindings.bindingInformation.split(":")[2] + ":" + $bindings.Bindings.bindingInformation.split(":")[1]
	write-host "Pinging $url"
	Invoke-WebRequest -Uri $url -usebasicParsing | Select StatusCode
}


# Helpers

function getrepo () {
	$repodir = git rev-parse --show-toplevel
	$repo = Split-Path $repodir -Leaf
	return $repo;
}

function regjump($val){
	$RegEditor_LastKey ="HKCU:Software\Microsoft\Windows\CurrentVersion\Applets\Regedit"

	#Get-ItemProperty -Path $RegEditor_LastKey -Name LastKey

	Set-ItemProperty -Path $RegEditor_LastKey -Name LastKey -Value  $val
	Start-Process "$env:windir\regedit.exe"
}
