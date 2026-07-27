const service = "org.nothingos.EdgeGroups";
const objectPath = "/EdgeGroups";
const iface = "org.nothingos.EdgeGroups";
const memberPrefix = "kwin-edge-";
const edgeDepth = 560;

let leftActive = false;
let rightActive = false;

function setHovered(group, hovered) {
    callDBus(service,
             objectPath,
             iface,
             "SetHovered",
             group,
             memberPrefix + group,
             hovered);
}

function updateEdgeGroups() {
    const cursor = workspace.cursorPos;
    const screen = workspace.screenAt(cursor);
    if (!screen) {
        return;
    }

    const geometry = screen.geometry;
    const belowStatusBar = cursor.y >= geometry.y + 48;
    const aboveDockZone = cursor.y < geometry.y + geometry.height - 96;
    const inWidgetHeight = belowStatusBar && aboveDockZone;
    const onLeft = inWidgetHeight && cursor.x <= geometry.x + edgeDepth;
    const onRight = inWidgetHeight
        && cursor.x >= geometry.x + geometry.width - edgeDepth;

    if (onLeft !== leftActive) {
        leftActive = onLeft;
        setHovered("left", leftActive);
    }
    if (onRight !== rightActive) {
        rightActive = onRight;
        setHovered("right", rightActive);
    }
}

workspace.cursorPosChanged.connect(updateEdgeGroups);
workspace.screensChanged.connect(updateEdgeGroups);
updateEdgeGroups();
