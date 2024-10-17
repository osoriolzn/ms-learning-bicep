# Crea un registro de aplicación en Microsoft Entra ID, agrega una entidad de servicio al inquilino de Microsoft Entra y crea una clave para el registro de la aplicación.
$servicePrincipal = New-AzADServicePrincipal -DisplayName MyPipeline

# Obtener la contraseña de la entidad de servicio, solo se puede obtener una sola vez.
$servicePrincipalKey = $servicePrincipal.PasswordCredentials.SecretText

Write-Output "Service principal application ID: $($servicePrincipal.AppId)"
Write-Output "Service principal key: $servicePrincipalKey"
Write-Output "Your Azure AD tenant ID: $((Get-AzContext).Tenant.Id)"

# Actualizar la contraseña de la entidad de servicio.
$applicationId = APPLICATION_ID
$servicePrincipalObjectId = (Get-AzADServicePrincipal -ApplicationId $applicationId).Id

Remove-AzADServicePrincipalCredential -ObjectId $servicePrincipalObjectId

$newCredential = New-AzADServicePrincipalCredential -ObjectId $servicePrincipalObjectId
$newKey = $newCredential.SecretText