
function npp($file) { & "C:\Program Files (x86)\Notepad++\notepad++.exe" $file}

function deploy-motormart-noprofile() {
	cd E:\MotorMart\Carfinance.MotorMart\
	#msbuild /p:BuildProjectReferences=false .\Carfinance.Motormart.Schema\Carfinance.Motormart.Schema.sqlproj
	& "C:\Program Files (x86)\Microsoft SQL Server\130\DAC\bin\SqlPackage.exe" /Action:Publish `
	/SourceFile:Carfinance.MotorMart.Schema/bin/debug/Carfinance.MotorMart.Schema.dacpac `
	/TargetDatabaseName:MotorMartLocal `
	/TargetServerName:localhost `
	/p:BlockOnPossibleDataLoss=true
}
