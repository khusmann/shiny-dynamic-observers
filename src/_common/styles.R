app_styles <- HTML("
html, body, .container-fluid {
  height: 100%;
  margin: 0;
  padding: 0;
}

.centered-content {
  display: flex;
  flex-direction: column;
  max-width: 48rem;
  margin: 0 auto;
  height: 100%;
  padding: 0 10px;
}

.card-container {
  flex: 1;
  margin-bottom: 15px;
  overflow-y: scroll;
  border: 1px solid #ccc;
  padding: 4px;
}

.card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 2px solid black;
  padding: 4px;
  margin: 0px;
  margin-bottom: 3px;
}

.message-container {
  height: 100px;
  border: 0px solid #ccc;
  padding: 0px;
  margin-bottom: 15px;
}

.message-container pre {
  height: 100%;
  overflow-y: scroll;
  box-sizing: border-box;
}
")
