## how to install kubectl

### download kubectl
curl -LO https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl
### install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
### check version
kubectl version --client



## install terraform

### Step 1: Install yum-config-manager


```sh
sudo yum install -y yum-utils
```

### Step 2: Add HashiCorp Linux Repository


```sh
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
```

### Step 3: Install Terraform


```sh
sudo yum -y install terraform
```

### Verifying the Installation

```sh
terraform -v
```