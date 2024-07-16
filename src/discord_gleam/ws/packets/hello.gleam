import gleam/dynamic

pub type HelloPacketData {
  HelloPacketData(heartbeat_interval: Int)
}
