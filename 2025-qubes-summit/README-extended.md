# Making of preloaded disposables

Slides that did not make the final cut.

---

## Developers template

Use Fedora stable or testing, else issues might arise:

* Linter versions might not warn of issues or warn of different issues (pylint)
* Formatters might format differently (black)
* GUI editors might make unwanted changes that are fixed on newer versions (glade)
* Test helpers might not contain packages of other templates

---

## OpenQA makes you regret not logging enough

* **Slow**: nested virtualization, Qubes under KVM
* **Diverse**: pool of certified systems
* **Low memory**: Tests are run with 8GB of RAM
  * Helps catch leaky objects (minimum system requirements)
  * Set Xen command-line option `availmem=8192M`
* **Fresh setup**, your local one isn't:
  * Reinstalls the OS after a full test run
  * Tests all default templates

---

## OpenQA tips

* Logging
* Don't rely on the openqa-bot comment on Github
* See available memory for the test at *Settings* -> *QEMURAM*
* Standard input may be open, explicit is better than implicit, redirect to `/dev/null`
* Valuable *Logs & Assets*: `journal.log`, `.xsession-erros`, `tests-qubes-tests-*.log`, `objgraph`, `guest.log`, `Video` (if slowed down at least 0.25x)

---

## Possible startup time improvements

Users can improve startup time:

* Software:
  * Minimal templates (less services enabled)
  * Minimal kernel (less modules loaded)
  * Faster filesystem (LVM, ZFS or BTRFS)
* Hardware:
  * Faster disk
  * Faster CPU

> Not exclusive to disposables

---

## Possible usage time improvements

Developers can improve preload usage time:

* Implement invisible mode in the GUI daemon
* Find bugs
* Provide a PoC for an alternate design, benchmark it and publish

---

## Leverage its power

* Qubes Admin API is synchronous, use threads for concurrency
* Search for *preload-dispvm* in the **qvm-features** manual page
* See the examples in the benchmark script `qubes-core-admin/tests/dispvm_perf.py`
* Enable concurrency based on the *max* feature:

```
# Qrexec Policy
admin.vm.feature.Get +preload-dispvm-max client default-dvm allow target=dom0
```

```
# Caller
qrexec-client-vm default-dvm \
  admin.vm.features.Get+preload-dispvm-max </dev/null
```

---

## Find problems and solve them

Here be dragons...

* GUI components shows preloaded disposables: `domain-feature-set:internal`
* Preload paused with more memory than it needs: New Qmemman API
* Detect incorrect usage: `domain-unpaused`
* Autostarted app before paused state: Late GUID
* Suspend messes with clock and memory consumption: Refresh
* Outdated volumes on template updates: Refresh
