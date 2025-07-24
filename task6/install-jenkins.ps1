# PowerShell Jenkins Installation Script

param (
    [string]$Namespace = "jenkins",
    [string]$ReleaseName = "jenkins",
    [string]$ValuesFile = "values.yaml"
)

function Exec($cmd) {
    # Write-Host "🔧 Running: $cmd"
    cmd /c $cmd
    # if ($LASTEXITCODE -ne 0) {
    #     throw "❌ Command failed: $cmd"
    # }
}

# Write-Host '📦 Adding Jenkins Helm repo...'
Exec 'helm repo add jenkins https://charts.jenkins.io'
Exec 'helm repo update'

# Write-Host '📁 Ensuring namespace '$Namespace' exists...'
$nsExists = kubectl get ns $Namespace -o name 2>$null
if (-not $nsExists) {
    Exec "kubectl create namespace $Namespace"
}

# Write-Host '🔐 Creating GitHub credentials secret...'
$githubSecret = @"
apiVersion: v1
kind: Secret
metadata:
  name: github-credentials
  namespace: $Namespace
type: Opaque
stringData:
  GITHUB_USERNAME: $GitHubUsername
  GITHUB_TOKEN: $GitHubToken
"@
$githubSecret | kubectl apply -f -

# Write-Host "🔐 Creating SonarQube token secret..."
$sonarSecret = @"
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-sonar-token
  namespace: $Namespace
type: Opaque
stringData:
  SONAR_TOKEN: $SonarToken
"@
$sonarSecret | kubectl apply -f -

# Write-Host '🚀 Installing Jenkins Helm chart...'
Exec "helm upgrade --install $ReleaseName jenkins/jenkins --namespace $Namespace -f $ValuesFile --reset-values"

# Write-Host '`n✅ Jenkins installed successfully in namespace [$Namespace]'

# Write-Host '`n🌐 Fetching Jenkins NodePort access info...'
$nodeIP = kubectl get nodes -o jsonpath="{.items[0].status.addresses[?(@.type=='ExternalIP')].address}"

if (-not $nodeIP) {
    # fallback to InternalIP if ExternalIP not found
    $nodeIP = kubectl get nodes -o jsonpath="{.items[0].status.addresses[?(@.type=='InternalIP')].address}"
}

# Write-Host '➡️  Access Jenkins at: http://$nodeIP`:$nodePort'
# Write-Host '👤 Default admin username: admin'
# Write-Host "🔑 Default admin password: password (check your values.yaml)"
