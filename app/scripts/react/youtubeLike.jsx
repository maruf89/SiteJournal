/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.youtube_like = React.createClass({

    componentDidMount: function () {
        // grab the selector
        this.selector = document.querySelector('[data-reactid="' + this._rootNodeID + '"]');

        // connect it with Angular's infrastructure so we can use the contollers
        this.props.compile(this.selector)(this.$scope);
    },

    render: function () {
        this.$scope = this.props.scope;

        var item = this.$scope.item;

        return (
            <article className="ytLike player item" data-ng-controller="youtubeVideo" data-ng-click="togglePlay()">
                <div className="tag">Y</div>
                <div className="container">
                    <img src={item.cover} data-ng-hide="playing" />
                    <div className="iframe" data-ng-show="playing">
                        <div id="instanceId-vid"></div>
                    </div>
                </div>
            </article>
        )
    }
})