$subscription = Read-Host -Prompt "Subscription ID"
$rg = Read-Host -Prompt "Resource Group"
$policyName = Read-Host -Prompt "Policy Name"
$output = @()


set-azcontext -Subscription $subscription | Out-Null

$policy = Get-AzFirewallPolicy -Name $policyName -ResourceGroupName $rg

foreach ($ruleCollectionGroup in $($policy.RuleCollectionGroups)){
    $collectionGroupName = $ruleCollectionGroup.Id.Split("/")[-1]
    $currentCollectionGroup = Get-AzFirewallPolicyRuleCollectionGroup -Name $collectionGroupName -ResourceGroupName $rg -AzureFirewallPolicyName $policyName
    foreach ($ruleCollection in $($currentCollectionGroup.Properties.RuleCollection)){
        foreach ($rule in $ruleCollection.rules){ 
            $output += [PSCustomObject]@{
                RuleCollectionGroupName = [string]$collectionGroupName
                RuleCollectionName = [string]$ruleCollection.Name
                RuleName = [string]$rule.Name
                RuleType = [string]$rule.RuleType
                SourceAddress = [string]$rule.SourceAddresses
                SourceIpGroups = [string]$rule.SourceIpGroups
                DestinationAddress = [string]$rule.DestinationAddresses
                DestinationIpGroups = [string]$rule.DestinationIpGroups
                Protocols = [string]$rule.Protocols
                DestinationPorts = [string]$rule.DestinationPorts
            }
        }
    }

}

$output | Export-Csv -Path "$($PWD.Path)\firewall-policy-rules.csv"
