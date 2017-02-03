{{/* Example template that reflects on the local AWS environment via User Metadata */}}

Information about this AWS instance:

IAM:
iam-info:		{{ $iam := include "http://169.254.169.254/latest/meta-data/iam/info" | from_json }}{{ to_json $iam }}
iam-profile-arn:	{{ $iam.InstanceProfileArn }}
iam-profile-id:		{{ $iam.InstanceProfileId }}
iam-role:		{{ include "http://169.254.169.254/latest/meta-data/iam/security-credentials" }}

availability-zone:	{{ include "http://169.254.169.254/latest/meta-data/placement/availability-zone" }}
ami-id:			{{ include "http://169.254.169.254/latest/meta-data/ami-id" }}
instance-type:		{{ include "http://169.254.169.254/latest/meta-data/instance-type" }}
sshkey:			{{ include "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key" }}
sshkey-name:		{{ $v := include "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key" | split " " }}{{ $v._2 }}

{{ $mac:= include "http://169.254.169.254/latest/meta-data/network/interfaces/macs"}}
{{ $netprefix:= cat "http://169.254.169.254/latest/meta-data/network/interfaces/macs/" $mac | nospace }}

mac:	     	     	{{ $mac }}
public-hostname:	{{ cat $netprefix "public-hostname" | nospace | include }}
public-ipv4:		{{ include "http://169.254.169.254/latest/meta-data/public-ipv4" }}
security-groups:	{{ cat $netprefix "security-groups" | nospace | include }}
security-group-ids:	{{ cat $netprefix "security-group-ids" | nospace | include }}
subnet-id:		{{ cat $netprefix "subnet-id" | nospace | include }}
vpc-id:			{{ cat $netprefix "vpc-id" | nospace | include }}




