
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
	#msbuild Carfinance.ContactCentre.Api.xproj /p:target=Publish /p:DeployOnBuild=true /p:PublishDir="E:\MotorMart\_Releases\Test\" /p:Configuration=Debug /p:Platform="Any CPU" # asp core RC
	dotnet publish "src\${service}.Api" -o E:\MotorMart\_Releases\$service
	
	# Set the secrets
	$jwtSecret = "" # TODO
	$clientSecret = "" # TODO
	
	& "E:\work\PowerShell\Replace-JsonValue.ps1" "E:\MotorMart\_Releases\$service\appsettings.json" -key:"JwtSecret" -value:$jwtSecret
	& "E:\work\PowerShell\Replace-JsonValue.ps1" "E:\MotorMart\_Releases\$service\appsettings.json" -key:"ClientSecret" -value:$clientSecret
	
  # TODO move this path to a variable
	$appsettings = "E:\MotorMart\_Releases\$service\appsettings.json"
	$appsettingsdev = "E:\MotorMart\_Releases\$service\appsettings.development.json"
  
  # Fix the incorrect connection strings - some projects are setup WRONG
	if ($appsettings | Test-Path) { (Get-Content $appsettings) | ForEach-Object {$_ -replace "=MotorMart;", "=MotorMartLocal;"} | Set-Content $appsettings }
	if ($appsettingsdev | Test-Path) { 
		(Get-Content $appsettingsdev) | ForEach-Object {$_ -replace "=MotorMart;", "=MotorMartLocal;"} | Set-Content $appsettingsdev 
		& "E:\work\PowerShell\Replace-JsonValue.ps1" "E:\MotorMart\_Releases\$service\appsettings.development.json" -key:"JwtSecret" -value:$jwtSecret
		& "E:\work\PowerShell\Replace-JsonValue.ps1" "E:\MotorMart\_Releases\$service\appsettings.development.json" -key:"ClientSecret" -value:$clientSecret
	}
	if ($service -eq "Carfinance.Application.Info") { (Get-Content "E:\MotorMart\_Releases\$service\${service}.api.exe.config") | ForEach-Object {$_ -replace "{connection-string}", "Data Source=localhost;Initial Catalog=MotorMartLocal;Integrated Security=True;"} | Set-Content "E:\MotorMart\_Releases\$service\${service}.Api.exe.config" }
	
	#Ping the Api to wake it up
	$bindings = Get-IISSite $service | Select Bindings
	$hostname = if($bindings.Bindings.bindingInformation.split(":")[2] -eq "" ){"localhost"} else {$bindings.Bindings.bindingInformation.split(":")[2]};
	$url = $bindings.Bindings.protocol + "://" + $hostname + ":" + $bindings.Bindings.bindingInformation.split(":")[1]
	write-host "Pinging $url"
	Invoke-WebRequest -Uri $url -usebasicParsing | Select StatusCode
}

function getrepo () {
	$repodir = git rev-parse --show-toplevel
	$repo = Split-Path $repodir -Leaf
	return $repo;
}

Export-ModuleMember -function dotnetpublish -Alias dotnet-publish
