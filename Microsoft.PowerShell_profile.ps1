
function npp($file) { & "C:\Program Files (x86)\Notepad++\notepad++.exe" $file}

#SQL
function deploy-motormart-noprofile() {
	cd E:\MotorMart\Carfinance.MotorMart\
	#msbuild /p:BuildProjectReferences=false .\Carfinance.Motormart.Schema\Carfinance.Motormart.Schema.sqlproj
	& "C:\Program Files (x86)\Microsoft SQL Server\130\DAC\bin\SqlPackage.exe" /Action:Publish `
	/SourceFile:Carfinance.MotorMart.Schema/bin/debug/Carfinance.MotorMart.Schema.dacpac `
	/TargetDatabaseName:MotorMartLocal `
	/TargetServerName:localhost `
	/p:BlockOnPossibleDataLoss=true
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
	
	# Inject the secrets
	#$json = Get-Content -path "appKeys.json" -Raw | ConvertFrom-Json
	#$clientSecret = $json.sites.$service
		
	$appsettings = "E:\MotorMart\_Releases\$service\appsettings.json"
	$appsettingsdev = "E:\MotorMart\_Releases\$service\appsettings.development.json"
	# Replace any incorrect values 
	if ($appsettings | Test-Path) { (Get-Content $appsettings) | ForEach-Object {$_ -replace "=MotorMart;", "=MotorMartLocal;"} | Set-Content $appsettings }	
}
