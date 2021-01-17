<?php
if (isset($_GET['ca'])) {
    $hostname = gethostname();
    $caname = "ca.orchard.$hostname.crt";
    header("Content-Disposition: attachment; filename=\"$caname\"");
    echo file_get_contents("/etc/apache2/ssl/$caname");
    exit;
}

if (isset($_GET['info'])) {
    phpinfo();
    exit;
}

?>

<html lang="en">
<style>
    /*! normalize.css v8.0.1 | MIT License | github.com/necolas/normalize.css */ html{line-height:1.15;-webkit-text-size-adjust:100%}body{margin:0}main{display:block}h1{font-size:2em;margin:.67em 0}hr{box-sizing:content-box;height:0;overflow:visible}pre{font-family:monospace,monospace;font-size:1em}a{background-color:transparent}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}b,strong{font-weight:bolder}code,kbd,samp{font-family:monospace,monospace;font-size:1em}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sub{bottom:-.25em}sup{top:-.5em}img{border-style:none}button,input,optgroup,select,textarea{font-family:inherit;font-size:100%;line-height:1.15;margin:0}button,input{overflow:visible}button,select{text-transform:none}[type=button],[type=reset],[type=submit],button{-webkit-appearance:button}[type=button]::-moz-focus-inner,[type=reset]::-moz-focus-inner,[type=submit]::-moz-focus-inner,button::-moz-focus-inner{border-style:none;padding:0}[type=button]:-moz-focusring,[type=reset]:-moz-focusring,[type=submit]:-moz-focusring,button:-moz-focusring{outline:1px dotted ButtonText}fieldset{padding:.35em .75em .625em}legend{box-sizing:border-box;color:inherit;display:table;max-width:100%;padding:0;white-space:normal}progress{vertical-align:baseline}textarea{overflow:auto}[type=checkbox],[type=radio]{box-sizing:border-box;padding:0}[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}[type=search]{-webkit-appearance:textfield;outline-offset:-2px}[type=search]::-webkit-search-decoration{-webkit-appearance:none}::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}details{display:block}summary{display:list-item}template{display:none}[hidden]{display:none}
    /***/

    h3 {
        margin-top : 5px;
    }
    body {
        font-family: sans-serif;
        background-color: #eee;
        display: flex;
        align-items: center;
        justify-content: center;
        min-height:100vh;
    }

    .cards {
        margin-top: 30px;
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-around;
    }

    code {
        background-color: #f2f2f2;
        font-family: serif;
        padding: 1px;
    }

    .card {
        align-self: stretch;
        box-sizing:border-box;
        padding: 10px;
        color: #444;
        border : 1px solid #999;
        width:30%;
        border-radius: 5px;
    }

    a.card {
        text-decoration: none;
    }

    a.card:hover {
        text-decoration: none;
        background-color: #fbfbfb;
    }

    a.card:hover h3 {
        text-decoration: underline;
    }

    .container {
        max-width: 840px;
        padding: 30px;
        color: #444;
        background-color: #fff;
    }

</style>
<body>
<div class="container">
  <div>
    <div style="float: left; padding-right: 20px;">
      <svg height='140px' width='140px' fill="#4D5E7C" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" x="0px" y="0px" viewBox="25 25 150 150" style="enable-background:new 0 0 200 200;" xml:space="preserve"><g><path d="M105.414,61.04c0,3.22-2.62,5.84-5.86,5.84c-3.24,0-5.88-2.62-5.88-5.84c0-3.2,2.64-5.82,5.88-5.82   C102.794,55.22,105.414,57.84,105.414,61.04z"></path><path d="M124.994,92.979c0,3.42-2.8,6.2-6.26,6.2s-6.26-2.78-6.26-6.2c0-3.4,2.8-6.18,6.26-6.18S124.994,89.579,124.994,92.979z"></path><path d="M155.999,143.143H44.001c-2.209,0-4,1.791-4,4s1.791,4,4,4h111.999c2.209,0,4-1.791,4-4S158.208,143.143,155.999,143.143z"></path><path d="M44.001,137.927h20c2.209,0,4-1.791,4-4s-1.791-4-4-4h-20c-2.209,0-4,1.791-4,4S41.792,137.927,44.001,137.927z"></path><path d="M116,156H44.001c-2.209,0-4,1.791-4,4c0,2.209,1.791,4,4,4H116c2.209,0,4-1.791,4-4C120,157.791,118.209,156,116,156z"></path><path d="M155.999,156h-20c-2.209,0-4,1.791-4,4c0,2.209,1.791,4,4,4h20c2.209,0,4-1.791,4-4   C159.999,157.791,158.208,156,155.999,156z"></path><path d="M155.994,129.919h-51.999v-14.26c4.16,2.44,8.98,3.78,13.96,3.78c14.94,0,27.08-11.86,27.08-26.42   c0-11.46-7.7-21.56-18.54-25.08c0.4-1.8,0.58-3.64,0.58-5.5c0-14.58-12.14-26.44-27.06-26.44c-14.94,0-27.1,11.86-27.1,26.44   c0,1.86,0.2,3.7,0.6,5.5c-10.84,3.54-18.54,13.62-18.54,25.08c0,14.56,12.14,26.42,27.08,26.42c4.98,0,9.78-1.34,13.94-3.78v14.26   h-12c-2.2,0-4,1.8-4,4c0,2.22,1.8,4,4,4h71.999c2.22,0,4-1.78,4-4C159.994,131.719,158.214,129.919,155.994,129.919z    M100.014,103.119c-1.18,0-2.3,0.52-3.06,1.42c-3.68,4.38-9.1,6.9-14.9,6.9c-10.52,0-19.08-8.26-19.08-18.42   c0-9.04,6.96-16.88,16.2-18.22c1.22-0.18,2.3-0.9,2.9-1.98c0.62-1.08,0.7-2.38,0.22-3.52c-0.92-2.18-1.38-4.48-1.38-6.86   c0-10.16,8.56-18.44,19.1-18.44c10.52,0,19.06,8.28,19.06,18.44c0,2.36-0.46,4.68-1.36,6.9c-0.46,1.14-0.38,2.42,0.24,3.5   c0.6,1.06,1.68,1.78,2.9,1.96c9.22,1.34,16.18,9.18,16.18,18.22c0,10.16-8.56,18.42-19.08,18.42c-5.8,0-11.22-2.52-14.88-6.88   C102.314,103.639,101.194,103.119,100.014,103.119z"></path></g></svg>
    </div>
    <h1>Welcome to Orchard</h1>
    <p>If you're seeing this, it means your Orchard is working correctly, congratulations !<p>
    <p>You can now add sites in <code>/var/www/</code> (which you can access from your windows host at <code>\\wsl$\Ubuntu\var\www</code>) and serve them with the <code>serve</code> command. Here are a few things that could come in handy :</p>
  </div>

  <div class="cards">
    <a href="https://github.com/nicolus/orchard" class="card">
      <h3>Documentation</h3>
      <p> Learn more about how to use orchard</p>
    </a>
    <a href="?ca" class="card">
      <h3>Download CA cert</h3>
      <p> You can add this CA certificate to your browser so that you local sites are seen as secure</p>
    </a>
    <a href="?info" class="card">
      <h3>PHP Info</h3>
      <p> A simple phpinfo() page to check that everything is configured to your liking</p>
    </a>
  </div>
</div>
</body>
</html>
