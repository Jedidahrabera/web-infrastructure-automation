# web-infrastructure-automation
# Technical Deployment Report: Web Infrastructure Automation & Cloud Redundancy

## 1. Executive Summary
This report details the implementation of an automated web infrastructure provisioning system, local monitoring health checks, and a cloud-integrated disaster recovery strategy. The environment utilizes an internal Ubuntu system integrated with AWS object storage. A full disaster recovery test was executed, simulating web assets deletion and successfully performing a remote restoration lifecycle.

---

## 2. Infrastructure Architecture & Network Diagram
The system structure separates public availability, local background system testing, and offsite secure backup data containment:

[ Administrative Machine ] ──> [ Ubuntu Web Server (jedidah) ] ──> [ AWS Cloud (eu-north-1) ]
                                  ├── Nginx Web Server            └── S3 Bucket: buckets3.rabera
                                  └── Local Cron Monitor Check

---

## 3. Automation Implementation (Ansible Configuration)
A structural declarative Ansible playbook template was deployed to automate packages updating, core firewall perimeter rules setup, and web infrastructure initialization:

- Installs Nginx Web Server engine.
- Configures UFW firewall parameters tightly to ports 22, 80, and 443.
- Activates system security state enforcement rules automatically.

---

## 4. Automation Scripts & Storage Redundancy Configuration

### A. Production Asset Archival Script (`backup_server.sh`)
```bash
#!/bin/bash
BACKUP_DIR="/tmp/server_backups"
BUCKET_NAME="buckets3.rabera"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="backup_$TIMESTAMP.tar.gz"
mkdir -p "$BACKUP_DIR"
sudo tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" /var/log/nginx /var/www/html
aws s3 cp "$BACKUP_DIR/$ARCHIVE_NAME" "s3://$BUCKET_NAME/$ARCHIVE_NAME"
rm "$BACKUP_DIR/$ARCHIVE_NAME"
```

### B. Service Verification Script (`monitor_nginx.sh`)
```bash
#!/bin/bash
echo "$(date): Status Code: $(curl -s -o /dev/null -w "%{http_code}" http://localhost)" >> ~/nginx_monitor.log
```

### C. System Cron Job Scheduling Setup
```text
0 0 * * * /home/jedidah/backup_server.sh       # Midnight Automated Cloud Backup
*/5 * * * * /home/jedidah/monitor_nginx.sh     # Every 5 Minutes Health Status Audit
```

---

## 5. Technical Challenges Faced & Troubleshooting Logic (Day 5 Proof)
During the deployment and verification phases, multiple structural blockers were systematically identified and resolved:

### A.Minor VM/network configuration adjustments while assigning static IPs and getting both VMs communicating on the Host-Only network. 
- **Resolution:** Adjusted Host-Only network settings and static IP assignments via Netplan until both VMs can ping each other successfully. 
### B.Hardware issue- HP laptop experienced intermittent hangs and Missing credentials- First backup attempt failed with Unable to locate credentials; Resolution: Running aws configure. 
- **Resolution:** Running aws configure
### C.Command syntax- A missing space in the aws s3 cp command caused a "paths required" error. 
- **Resolution:** Corrected the spacing. 
### D.Disaster test (over-deletion): Deleted the entire /var/www/html/ directory instead of just index.html; recreated the directory before restoring a more thorough test than planned. 
- **Resolution:** AWS access keys were visible in a few screenshots during documentation; the exposed key was deactivated, deleted, and replaced immediately. 
### E.New credentials returned SignatureDoesNotMatch due to a mistyped secret key. resolved by re-entering it via copy-paste instead of manual typing.  
- **Resolution:** Manually forced hardware clock time synchronization alignments utilizing: `sudo date -s "15:02:00"` and `sudo hwclock --hctosys` to instantly normalize the server timeline. 
### F.Cloud Access Denied Violations (`403 Forbidden`). 
- **Resolution:**  Re-entered clean programmatic credentials securely associated with IAM user `Ida@Nyandoro`, validating correct `s3:GetObject` privileges. 
Manually forced hardware clock time synchronization alignments utilizing:
  `sudo date -s "15:02:00"` and `sudo hwclock --hctosys` to instantly normalize the server timeline.
### G. Final Validation and Recovery Proof
Following configuration corrections, the asset recovery pipeline executed with zero syntax faults:
1. **Cloud Fetch:** `aws s3 cp s3://buckets3.rabera/backup_20260721_081118.tar.gz .` pulled down the object successfully.
2. **Extraction Restoration:** `sudo tar -xzf backup_20260721_081118.tar.gz -C /` successfully unpacked and restored all web root code assets and logging files back to their live operational states.
 
---

## 6. Verification Records (Sample Monitor Log Output)

```text

Tue Jul 21 10:43:09 AM UTC 2026: Status Code: 200
wed Jul 22 12:36:07 PM UTC 2026: Status Code: 000

```
