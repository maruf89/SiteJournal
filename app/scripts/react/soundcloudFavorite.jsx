/** @jsx React.DOM */

var MVItems = MVItems || {};

MVItems.soundcloud_favorite = React.createClass({

    componentDidMount: MVItems.proto.componentDidMount,

    togglePlay: function () {
        this.$scope.togglePlay();
    },

    seek: function (e) {
        this.$scope.seek(e);
    },

    render: function () {
        var item = this.props.item;

        return (
            <article className="scSound player item" data-ng-controller="soundcloudMusic" onClick={this.togglePlay}>
                <h3>{item.title}</h3>
                <div className="music-row">
                    <div className="artwork">
                        <img src={item.artwork_url} />
                    </div>
                    <div className="waveform" onClick={this.seek}>
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