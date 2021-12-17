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
| Image | Solved DP-403123 | Has embedded Python | Error | Final result
|-|-|-|-|-|
| containers.intersystems.com/iscinternal/iris:2021.2.0XDBCQD.105.0 | No | No || Failed
| containers.intersystems.com/iscinternal/iris:2021.2.0XDBC.158.0 | Yes | No || Passed (without python)
| arti.iscinternal.com/intersystems/iris:2021.1.0PYTHON.222.0 | ? | Yes | E1 | Failed
| arti.iscinternal.com/intersystems/iris:2021.1.0PYTHON.238.0 | ? | Yes | E2 | Failed
| arti.iscinternal.com/intersystems/iris:2021.1.0PYTHON.254.0 | ? | Yes | E1 | Failed
| arti.iscinternal.com/intersystems/iris:2021.1.0PYTHON.259.0 | ? | Yes | E3 | Failed
| arti.iscinternal.com/intersystems/iris:2021.1.0PYTHON.286.0 | ? | Yes | E1 | Failed
| arti.iscinternal.com/intersystems/iris:2021.2.0.619.0 | No | Yes | E1 | Failed

The column "Successfully Patched in K8s" means that we were able to deploy the image in K8s and then patch it successfully. This was the main issue we were facing. While investigating this proble, we were also trying to see if we could jump to a Embedded Python image as well. That is why we also have the column "Python" above to indicate that this image has embedded python. 

The column "Error" refers to another error found when we were just trying to build the image:
| Error # | Type | Error |
|-|-|-|
| E1 | Runtime | An error was encountered while initializing the system. Please see the clone.log and messages.log files in /usr/irissys/mgr/ and /irissys/data/IRIS/mgr.[ERROR] Command "iris start IRIS quietly" exited with status 256
| E2 | Image build | IRISConfig.Installer: ERROR #5002: ObjectScript error: <OBJECT DISPATCH>zInstall+23^%SYS.Python.1 *Failed to load python!!" when trying to install PyYaml during image build. |
| E3 | Image Build | ERROR #5002: ObjectScript error: zInstall+30^%SYS.Python.1^1^ *<class 'ImportError'>: */usr/irissys/lib/python3.8/lib-dynload/_struct.cpython-38-x86_64-linux-gnu.so: undefined symbol: PyFloat_Type - <class 'ImportError'>: /usr/irissys/lib/python3.8/lib-dynload/math.cpython-38-x86_64-linux-gnu.so: undefined symbol: PyFloat_Type - iris loader failed

The "Runtime" error can be reproduced by running scripts 1 to 3 so that thei IRIS image is deployed in the Kubernetes cluster using helm.

The "Image Build" error is reproduced by running the './build.sh' script in the **image** folder. But you may need to edit the 'build.sh' script to use the correct TAG.



