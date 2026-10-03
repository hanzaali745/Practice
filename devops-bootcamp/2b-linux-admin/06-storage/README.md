# Linux Module 06 — Storage: Disks, File Systems & LVM 🔴

## 🎯 Objectives
- See every disk, partition and file system on a machine (`lsblk`, `blkid`, `findmnt`, `df`)
- Partition a disk (GPT), create a file system, mount it, and make it permanent in `/etc/fstab` — safely
- Add swap
- Use **LVM** to pool disks and grow a volume while it's in use
- Know how this maps to the cloud: EBS volumes, resizing, snapshots

## 🧠 Why DevOps engineers care
"Add a data disk to the database server", "the volume is full — grow it without downtime", "the server didn't come back
after reboot because of fstab" — these are classic tickets. Cloud volumes (AWS EBS), Kubernetes PersistentVolumes and
Docker's `/var/lib/docker` are all block devices and file systems underneath.

---

## 🧪 Safe practice disks
The labs never touch a real disk: they create **image files** and attach them as **loop devices** (`/dev/loopN`) —
the kernel treats them exactly like disks. `lab-disks.service` re-attaches them at boot so your fstab entries work after
a reboot, like real disks would. (LVM needs the kernel's device-mapper: a VM has it; containers and WSL may not.)

---

## 📖 Lesson 6.1 — What's attached?

```bash
lsblk -f                      # tree of disks → partitions → file systems, with mount points and UUIDs
blkid                         # identifiers: UUID, TYPE, LABEL, PARTUUID
findmnt; findmnt /data        # what is mounted where, with which options
df -hT                        # usage per mounted file system (and its type)
```
Names: `/dev/sda`, `/dev/vda`, `/dev/nvme0n1` (disks) → `sda1`, `nvme0n1p1` (partitions). **Names can change between
boots** (add a disk and `sdb` becomes `sdc`) — that's why fstab uses **UUIDs**.

## 📖 Lesson 6.2 — Partition, format, mount

```bash
sudo parted /dev/vdb --script mklabel gpt mkpart data ext4 1MiB 100%   # GPT, one partition using the whole disk
sudo mkfs.ext4 -L data /dev/vdb1                                        # a file system (xfs: mkfs.xfs) — ERASES it
sudo mkdir -p /data && sudo mount /dev/vdb1 /data                       # mount now
sudo blkid -s UUID -o value /dev/vdb1                                   # its UUID
echo 'UUID=1234-...  /data  ext4  defaults,nofail  0  2' | sudo tee -a /etc/fstab
sudo findmnt --verify && sudo systemctl daemon-reload && sudo mount -a  # TEST fstab before you reboot!
```
fstab fields: **what** (UUID=…) · **where** · **type** · **options** · dump (0) · fsck order (0 none, 1 root, 2 others).
`nofail` means a missing disk doesn't stop the boot — without it, a detached volume drops the server into emergency mode.
**Before any `mkfs`, check twice that it's the right device** (`lsblk`): it erases everything.

## 📖 Lesson 6.3 — Swap

```bash
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
swapon --show; free -h
```
Swap lets the kernel move rarely used memory to disk, avoiding OOM kills under short spikes — but heavy swapping makes
everything slow. `vm.swappiness` (Module 07) tunes how eagerly it's used. Kubernetes nodes traditionally run without swap.

## 📖 Lesson 6.4 — LVM: flexible volumes

```
 disks/partitions → PV (physical volume) → VG (volume group: a pool) → LV (logical volume) → file system
   /dev/vdb, /dev/vdc     pvcreate              vgcreate labvg            lvcreate -n data      mkfs.ext4
```
```bash
sudo pvcreate /dev/vdb /dev/vdc
sudo vgcreate labvg /dev/vdb /dev/vdc           # one 2-disk pool
sudo lvcreate -L 500M -n data labvg             # /dev/labvg/data  (= /dev/mapper/labvg-data)
sudo mkfs.ext4 /dev/labvg/data
sudo lvextend -r -L +300M labvg/data            # grow the volume AND the file system (-r), while mounted
sudo vgextend labvg /dev/vdd                    # out of space in the pool? add a disk
pvs; vgs; lvs                                   # summaries
```
ext4 and xfs grow online; ext4 can only **shrink** offline and xfs not at all — so start small and grow. LVM also does
snapshots (`lvcreate -s`) for consistent backups.

## 📖 Lesson 6.5 — In the cloud

- A new **EBS volume** shows up as a new disk (`lsblk`): partition (or not), mkfs, mount, fstab with UUID and `nofail`.
- **Growing** an EBS volume: modify it in AWS → `sudo growpart /dev/nvme0n1 1` (grow the partition) →
  `sudo resize2fs /dev/nvme0n1p1` (ext4) or `sudo xfs_growfs /` (xfs). No reboot.
- **Snapshots** are the cloud's block-level backups (Phase 11). Instance-store disks vanish when the instance stops.

---

## ⚠️ Common mistakes
- `mkfs` on the wrong device — always `lsblk` first
- `/dev/sdb1` in fstab instead of `UUID=`; no `nofail` on data disks; rebooting without `mount -a` to test fstab
- Mounting over a directory that already had files (they're hidden, not gone) — and then being confused by `du`
- Growing the volume but forgetting the file system (or the partition) on top
- Treating swap as a fix for an app that simply needs more memory

---

## 🧪 Labs
On your lab VM. Reference solution: [`solutions/labs.sh`](solutions/labs.sh) (and [`solutions/lab-disks`](solutions/lab-disks)).
Check: `sudo lab/check.sh 06`.

### Lab 1 ⭐ — Practice disks
Create `/var/lib/lab-disks/disk1.img` (1 GiB) and `disk2.img`, `disk3.img` (512 MiB each) with `truncate`. Attach them
with `losetup --find --show --partscan`. Write a tiny `lab-disks.service` (oneshot, before `local-fs-pre.target`) that
re-attaches them at boot. See them in `lsblk`.

### Lab 2 ⭐⭐ — A data disk
Partition disk1 (GPT, one partition), format it ext4, mount it on `/data`, and add it to `/etc/fstab` **by UUID with
nofail**. Run `findmnt --verify` and `mount -a`. Reboot and check it's back.

### Lab 3 ⭐ — Swap
A 256 MiB swap file at `/data/swapfile`, active now and in fstab.

### Lab 4 ⭐⭐⭐ — LVM
Make disk2 and disk3 one volume group `labvg`, create a 500 MiB volume `data`, ext4, mounted on `/srv/data` (fstab).
Write a file there, then grow the volume by 300 MiB **while it's mounted** and show the file system grew with `df -h`.

---

## ✅ Checkpoint
- [ ] I can read lsblk, blkid, findmnt and df and say what's on every disk
- [ ] I can partition, format and mount a disk, and write a safe fstab entry (UUID, nofail, tested)
- [ ] I can add swap
- [ ] I can build an LVM volume and grow it online
- [ ] I know how to grow a cloud volume without downtime
- [ ] `sudo lab/check.sh 06` passes (LVM checks need a VM)

👉 Next: [Module 07 — Processes, Resources & the Kernel](../07-processes-and-kernel/README.md)
