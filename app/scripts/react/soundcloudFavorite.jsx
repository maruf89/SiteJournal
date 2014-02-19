/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.soundcloud_favorite = React.createClass({

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
            <article className="scSound player item" data-ng-controller="soundcloudMusic" data-ng-click="togglePlay()">
                <h3 ng-bind={item.title}></h3>
                <div className="music-row">
                    <div className="artwork">
                        <img src={item.artwork_url} />
                    </div>
                    <div className="waveform" data-ng-click="seek($event)">
                        <div className="cover">
                            <img src={item.waveform_url} />
                        </div>
                        <div className="background-color"></div>
                    </div>
                </div>
            </article>
        )
    }
})