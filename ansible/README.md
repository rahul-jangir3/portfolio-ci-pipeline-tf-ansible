# 🚀 Ansible Automation for Nginx Website Deployment

This repository demonstrates how to deploy a website on an AWS EC2 instance using **Ansible** and **Nginx**.  
Follow the steps below to set up your inventory, test the connection, and deploy your website.

---

## 📌 Step 1: Create Inventory File and Test Connection

Create a file named **`inventory.ini`** and add your EC2 server details:

```ini
[ec2]
<YOUR_SERVER_IP> ansible_user=ubuntu ansible_ssh_private_key_file=./<your-key>.pem
```

Check if Ansible can connect to the server:
```
ansible -i inventory.ini ec2 -m ping
```
If the connection is successful, you’ll see a pong response.

⚡ Step 2: Create Playbooks and Project Structure
Organize your files in the following structure:
```
.
├── main.yml
├── Playbooks/
│   ├── env.yml
│   ├── app.yml
│   └── deploy.yml
└── inventory.ini
```
▶️ Step 3: Run the Playbook

Run the main.yml playbook to deploy your website:
```
sudo ansible-playbook -i inventory.ini main.yml
```
Thanks....
