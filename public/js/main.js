HyperCount = React.createClass({
  render: function() {
    return (
      <div class="header">
        <h1>HyperCounter</h1>
        <a class="create" href="#">+</a>
      </div>
      <div class="counter-list-container">
        <ul class="counter-list">
          <li class="counter">
            <h2>My first counter</h2>
            <span class="value">123</span>
            <a class="decrement" href="#">-</a>
            <a class="increment" href="#">+</a>
          </li>
          <li class="counter">
            <h2>My first counter</h2>
            <span class="value">123</span>
            <a class="decrement" href="#">-</a>
            <a class="increment" href="#">+</a>
          </li>
        </ul>
      </div>
    );
  }
});


React.render(
  <HyperCount accountId={window.accountId} />,
  document.getElementById('app')
);
