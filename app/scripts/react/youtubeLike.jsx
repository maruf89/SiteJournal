/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.youtube_like = React.createClass({

    componentDidMount: function () {
        MVItems.proto.componentDidMount.call(this);

        this.$scope.setup()
    },

    togglePlay: function () {
        this.$scope.togglePlay();
    },

    render: function () {
        var item = this.props.item;

        return (
            <article className="ytLike player item" data-ng-controller="youtubeVideo" onClick={this.togglePlay}>
                <div className="tag">Y</div>
                <div className="container">
                    <img src={item.cover} data-ng-hide="playing" />
                    <div className="iframe" data-ng-show="playing">
                        <div id="{{instanceId}}-vid"></div>
                    </div>
                </div>
            </article>
        )
    }
})