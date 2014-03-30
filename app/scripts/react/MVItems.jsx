/** @jsx React.DOM */

var MVItems = {
    proto: {
        componentDidMount: function() {
            // grab the selector
            this.selector = document.querySelector('[data-reactid="' + this._rootNodeID + '"]');

            // connect it with Angular's infrastructure so we can use the contollers
            angular.$compile(this.selector)(this.props.scope);
            
            this.props.scope = this.$scope = this.props.scope.$$childTail;
            this.$scope.item = this.props.item;
        },

        count: 0
    }
}