# Google Colab Local Runtimes

## Setup instructions

### Step 1: Install Jupyter

Install [Jupyter](https://jupyter.org/install) on your local machine.

```
pip install notebook
```

### Step 2: Install and enable the 'jupyter_http_over_ws' jupyter extension (one-time)

The 'jupyter_http_over_ws' extension is authored by the Colaboratory team and available on [GitHub](https://github.com/googlecolab/jupyter_http_over_ws).

```
pip install jupyter_http_over_ws
jupyter serverextension enable --py jupyter_http_over_ws
```

### Step 3: Start server and authenticate

New notebook servers are started normally, though you will need to set a flag to explicitly trust WebSocket connections from the Colaboratory frontend.

```
python -m jupyter notebook --ip=0.0.0.0 --port=58888 --no-browser --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='https://colab.research.google.com' --NotebookApp.port_retries=0
```

Once the server has started, it will print a message with the initial backend URL used for authentication. Make a copy of this URL as you'll need to provide this in the next step.

### Step 4: Connect to the local runtime

In Colaboratory, click the "Connect" button and select "Connect to local runtime...". Enter the URL from the previous step in the dialog that appears and click the "Connect" button. After this, you should now be connected to your local runtime

### Uninstallation

You can disable and remove the jupyter_http_over_ws jupyter extension by running the following:

```
jupyter serverextension disable --py jupyter_http_over_ws
pip uninstall jupyter_http_over_ws
```
