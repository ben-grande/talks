---
title: Fast and fresh disposable qubes
date: 2025-09-27
author: Benjamin Grande
styles:
  author:
    bg: default
    fg: '#43c4f3'
  date:
    bg: default
    fg: '#777'
  headings:
    '1':
      fg: '#3874d8,bold'
    '2':
      fg: '#3874d8,bold'
    '4':
      fg: '#99bfff,bold'
  margin:
    bottom: 0
    left: 4
    right: 4
    top: 0
  padding:
    bottom: 0
    left: 4
    right: 4
    top: 0
  slides:
    bg: default
    fg: '#43c4f3'
  style: monokai
  table:
    column_spacing: 3
  title:
    fg: '#63a0ff,bold,italics'
---

# Fast and fresh disposable qubes

## Reviving a decade old issue

----------------------------------- *Qubes OS Summit 2025*

---------------------------------------- *Benjamin Grande*

---

## Table of Contents

* Who am I
* Why disposables usage is slow
* How preloaded disposables can help
* Demo, benchmark
* Acknowledgments, Contact, References, QA

---

## What's my jam

* FOSS maintainer and contributor
  * Qubes
    * Management: qubesd, Admin API, qmemman
    * Frontend: GTK and Qt
    * Terminal apps: vim-qrexec, qubes-policy-lint, qubes-policy-editor
    * Orchestration: qusal
  * Kicksecure/Whonix
  * Other FOSS projects
* Sports:
  * Trail hikes
  * Table tennis

---

## What are disposables

Pristine qubes:

* **Security** improvement
* **Consistent** environment

Types:

* **Named** disposables
* **Unnamed** disposables

---

## Getting a fresh disposable is slow

Request:

1. Disk operations
1. Qube startup
1. Qrexec agent startup
1. GUI agent startup (only for GUI applications)

---

## Users circumvent slowness already

* Open files on non-fresh disposables -> *Dirty*
* Do other tasks in the meantime -> *Context switching*

```
   -----------------------------------
  | Not my problem, I can multi-task! |
   -----------------------------------
  /    ----------------------------------------
 O    | How many tasks until your focus drops? |-- O
/|\    ----------------------------------------   /|\
 |                                                 |
/ \ Alice                                     Bob / \
```

---

## Decade old issue

* 2015-12-13: *qubesuser*: Opens issue #1512
* 2015-12-22: *Marek*: Too late for R3.1, maybe on R4.0
* 2025-02-12: *Ben*: I think I can do it in 15 days
* 2025-09-27: *Ben*: Still fixing issues...

---

## Requirements for preloaded disposables

* **Usage time**: Almost* instant
* **Memory footprint**: Low
* **Security**: Preserved
* **Transparency**: Caller preserved

---

## Alternatives considered

* **Dump file**: Suspend to disk is unreliable (used in R3.2):
  * Incompatible with multiple vcpus
  * Some memory issues


* **Xen VM forking**: Unreliable and insecure:
  * Not designed for long sessions
  * Too much shared information


* **Queue**: Preload architecture minor issues:
  * Allocates memory for qubes in queue
  * GUI patching

---

## Let's do it

* What Qubes OS has: existent resources
* What we want: design
* How we did it: code samples

---

### Client-server

* **Server**: core-admin, *qubes* module, `qubesd`, `qmemman` etc
* **Client**: core-admin-client, *qubesadmin* module, `qvm-*`, GUI and audio daemon etc

---

### Qubesd is event-driven

```python3
class QubesVM(vm.mix.net.NetVMMixin, vm.LocalVM):

  def start(*args, **kwargs):
      vm.fire_event("domain-start")

  @qubes.events.handler("domain-start"):
  def domain_start_event(self, event, *args, **kwargs):
      self.log.info(
        "Qube '%s' received event '%s'",
        self.name, event
      )
```

---

### Life-cycle design

1. **Queued**:
  * Preloads are queued. Hidden from most GUI applications
  1.  **Startup**:
    * Starts qube, waits for services to conclude, pause qube
  1. **Request**:
    * Qube is removed from the preload list
1. **Used**:
  * Preload is unpaused, marked as used and becomes visible in GUI applications
  * Preloads another qube

---

### Queue design

Queue:

```diff
  1. Disk operations
  2. Qube startup
  3. Qrexec agent startup
+ 4. Wait for system to be fully operational
+ 5. Pause: some slowdown due to qmemman (only if not requested)
```

Request:

```diff
+ 1. Unpause (only if paused)
  2. GUI agent startup (only for GUI applications)
```

---

### Reporting fully operational system

Qrexec service `qubes.WaitForRunningSystem`:

* Any template shipped by Qubes OS
* Qubes Windows Tools may support it in the near future

---

### Important features

What you, as a user, need to know:

* **preload-dispvm-max** (global and local)
* **preload-dispvm-threshold** (global)

Workflows:

* **default-dvm** (global):
  * Browsing, file conversion, anything actually
* **default-mgmt-dvm** (local):
  * Ansible or Salt: same value as `--max-concurrency` (not implemented yet)
  * Console: `qvm-console-dispvm`
* **qubes-builder-dvm** (local):
  * Qubes Builder V2: Qubes Executor

---

### Autostart service

Systemd unit *qubes-preload-dispvm*:

* Controls autostart
* Refresh != refill

---

### Worry-free life-cycle

Gaps can momentarily happen from time to time:

* Insufficient memory
* Failure to preload
* Outdated volumes (template updates)
* Interrupted qubesd

They will be capped by qubesd events.

> Worry-free for the user, developer drought in tears.

---

## Users

They exist:

* R4.3 users
  * Enabled by default in the installer if >15GB of RAM
  * Release candidates testers gave valuable feedback
* Securedrop: file conversion, file viewer, web navigation
* Dangerzone: file conversion

> Freedom of the Press Foundation projects have open issues, no usage yet.

---

## Demo or not real

* App menu
* QUI domains
* Qube settings
* Global config
* Qube's file manager context menu

---

## Benchmark and scaling

* Sequential and concurrent
* Originating from dom0 or from qube
* GUI vs headless
* Normal vs preloaded
* Different templates

> There is not enough time to show each graph :(

---

## Considerations

* Pristine disposables are more secure
* Preloaded disposables lowers the bar
* Usage speed is UX, better UX is better security

---
## Acknowledgments

* ITL Qubes Team
* Qubes Community

---

## Contact

* Benjamin Grande M. S.
* Email: <ben.grande.b@gmail.com>
* Github: <https://github.com/ben-grande>
* Codeberg: <https:///codeberg.org/ben.grande.b>
* PGP code key: DF38 3487 5B65 7587 13D9 2E91 A475 969D E4E3 71E3
* PGP e-mail key: CCDD 547A 4AD5 E5A2 EA6F 0934 96A5 15DC 1EB9 622F

---

## References

* Meta issue: <https://github.com/QubesOS/qubes-issues/issues/1512>
* Qrexec: <https://www.qubes-os.org/doc/qrexec/>
* Admin API: <https://www.qubes-os.org/doc/admin-api/>
* qvm-features manual:
  <https://dev.qubes-os.org/projects/core-admin-client/en/latest/manpages/qvm-features.html>
* Core Admin: <https://github.com/QubesOS/qubes-core-admin>
* Management qube naming scheme: <https://mail-archive.com/qubes-devel@googlegroups.com/msg05635.html>

---

## Thoughts

```text
 .--------------.   .--------------.   .--------------.
| .------------. | | .------------. | | .------------. |
| |   ______   | | | |   ______   | | | |   ______   | |
| |  / _ __ `. | | | |  / _ __ `. | | | |  / _ __ `. | |
| | |_/ ___) | | | | | |_/ ___) | | | | | |_/ ___) | | |
| |    / ___.' | | | |    / ___.' | | | |    / ___.' | |
| |    |_|     | | | |    |_|     | | | |    |_|     | |
| |    (_)     | | | |    (_)     | | | |    (_)     | |
| |            | | | |            | | | |            | |
| '------------' | | '------------' | | '------------' |
 '--------------'   '--------------'   '--------------'
```
