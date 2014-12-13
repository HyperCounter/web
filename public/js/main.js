var HyperCount = React.createClass({
  getInitialState: function() {
    return {counters: []};
  },

  handleClick: function(counter, delta, event) {
    event.preventDefault();
    $.ajax('/counters/:id'.replace(':id', counter.id), {
      type: 'PUT',
      data: {delta: delta}
    }).done(function(data) {
      var old_counters = _.clone(this.state.counters, true);
      var updated_counters = _.map(old_counters, function(counter) {
        if(counter.id == data.id) {
          return data;
        } else {
          return counter;
        }
      }.bind(this));
      this.setState({counters: updated_counters});
    }.bind(this));
  },

  componentDidMount: function() {
    $.getJSON('/counters', function(data) {
      this.setState({counters: data})
      console.log(this.state)
    }.bind(this));
  },

  render: function() {
    return (
      <div>
        <div className="header">
          <h1>HyperCounter</h1>
          <a className="create" href="#">+</a>
        </div>
        <div className="counter-list-container">
          <ul className="counter-list">
            {this.renderCounters(this.state.counters)}
          </ul>
        </div>
      </div>
    );
  },

  renderCounters: function(counters) {
    return this.state.counters.map(function(c){
      return this.renderCounter(c);
    }.bind(this));
  },

  renderCounter: function(counter) {
    handler = (function(delta) { return this.handleClick.bind(null, counter, delta) }).bind(this);
    return (
      <li className="counter" key={counter.id}>
        <p className="small">{counter.id}</p>
        <h2>{counter.name}</h2>
        <span className="value">{counter.value}</span>
        <a className="decrement" href="#" onClick={handler(-1)}>-</a>
        <a className="increment" href="#" onClick={handler(1)}>+</a>
      </li>
    );
  }

});


React.render(
  <HyperCount accountId={window.accountId} />,
  document.getElementById('app')
);
