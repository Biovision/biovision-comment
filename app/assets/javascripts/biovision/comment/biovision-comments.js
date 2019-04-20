"use strict";

const Comments = {
    initialized: false,
    autoInit: true,
    components: {},
    init: function () {
        for (let component in this.components) {
            if (this.components.hasOwnProperty(component)) {
                if (this.components[component].hasOwnProperty("init")) {
                    this.components[component].init();
                }
            }
        }

        this.initialized = true;
    }
};

Comments.components.replyFormMover = {
    initialized: false,
    listContainer: undefined,
    mainContainer: undefined,
    form: undefined,
    /**
     * @type {HTMLElement}
     */
    parentId: undefined,
    replyButtons: [],
    cancelButtons: [],
    replySelector: ".comment-reply-button button",
    cancelSelector: ".container button.cancel",
    init: function () {
        this.listContainer = document.getElementById("comments");
        this.form = document.getElementById("comment-form");

        if (this.listContainer && this.form) {
            this.parentId = document.getElementById("comment_parent_id");
            this.mainContainer = this.listContainer.querySelector(".reply-container .container");
            this.listContainer.querySelectorAll(this.replySelector).forEach(this.applyToReplyButton);
            this.listContainer.querySelectorAll(this.cancelSelector).forEach(this.applyToCancelButton);

            this.initialized = true;
        }
    },
    /**
     *
     * @param {HTMLElement} button
     * @type {Function}
     */
    applyToReplyButton: function (button) {
        const component = Comments.components.replyFormMover;

        component.replyButtons.push(button);
        button.addEventListener("click", component.move);
    },
    /**
     *
     * @param {HTMLElement} button
     * @type {Function}
     */
    applyToCancelButton: function (button) {
        const component = Comments.components.replyFormMover;

        component.cancelButtons.push(button);
        button.addEventListener("click", component.cancel);
    },
    /**
     *
     * @param {Event} event
     * @type {Function}
     */
    move: function (event) {
        const component = Comments.components.replyFormMover;
        const button = event.target;
        const container = button.closest(".comment-reply-block").querySelector(".container");

        if (container) {
            component.parentId.value = button.closest(".comment-item").getAttribute("data-id");
            container.appendChild(component.form);
            container.classList.remove("hidden");
        }
    },
    /**
     *
     * @param {Event} event
     * @type {Function}
     */
    cancel: function (event) {
        const component = Comments.components.replyFormMover;
        const button = event.target;
        button.parentNode.classList.add("hidden");

        component.parentId.value = "";
        component.mainContainer.appendChild(component.form);
    }
};

Biovision.components.comments = Comments;
