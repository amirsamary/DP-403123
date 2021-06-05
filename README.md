# DP-403123

Use this to reproduce the error:

```
[ERROR] Command "iris start IRIS quietly" exited with status 256
06/04/21-22:18:43:542 (392) 0 [Utility.Event] ISC_DATA_DIRECTORY=/irissys/data/IRIS
06/04/21-22:18:43:542 (392) 0 [Utility.Event] Executing /usr/irissys/bin/iris qlist
06/04/21-22:18:43:550 (392) 3 [Utility.Event] Error during Upgrade,ERROR #5001: Unable to find Registry entry for directory /usr/irissys
[ERROR] See /irissys/data/IRIS/mgr/messages.log for more information
[FATAL] Error starting InterSystems IRIS
```

# Steps to reproduce it

These steps should work on a Mac or Linux. Make sure you have installed:
* k3d
* helm

Clone this repository. Make sure you put a valid `iris.key` file in the folder `iris-license`.

Run each script one after the other. Start with `1-create-cluster.sh`. This script will use k3d to create a simple Kubernetes cluster on your machine.

Then run `2-deploy-iko.sh`. This script will deploy IKO on your cluster. We are using **IKO version 2.1.0.66**.

When IKO is deployed and ready, run script `3-deploy-iris.sh`. This script will use the helm chart in this Git repository 
to deploy IRIS in your cluster with the same configurations we are using on ours. You can change its values.yaml file to
use a different IRIS version. We are currently using build `2021.2.0XDBCQD.105.0` because that is the build that Sam Fergunson
told us that he thought would work.

After you observe the issue, you can try again by running `helm delete test-iris` and waiting for the chart to be deleted from
your cluster. Then run `3-deploy-iris.sh` again. This script will make sure the Persistent Volume Claims from a previous try are removing so you can start again.

After some tests, if IKO stops responding and refuses to deploy IRIS, you can kill IKO's pod and it will get automatically recreated. After that, you can try again and IRIS will be deployed. I believe this is another issue we should be fixing. IKO will stop responding for some reason.

# IRIS Images tested

The following images have been tested:
* containers.intersystems.com/iscinternal/iris:2021.2.0XDBCQD.105.0
  * Result: failed to redeploy
* containers.intersystems.com/iscinternal/iris:2021.2.0XDBC.158.0
  * Result: Succeeded to redeploy!
* arti.iscinternal.com/intersystems/iris:2021.1.0PYTHON.238.0
  * Result: Succeeded to redeploy! 
  * But I am getting the error "#8 8.817 2021-06-05 03:05:22 0 IRISConfig.Installer: ERROR #5002: ObjectScript error: <OBJECT DISPATCH>zInstall+23^%SYS.Python.1 *Failed to load python!!" when trying to install PyYaml during image build.
* arti.iscinternal.com/intersystems/iris:2021.1.0PYTHON.222.0
  * Result: Succeeded to redeploy!
  * 


