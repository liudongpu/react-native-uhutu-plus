import React, { Component, PropTypes } from 'react';
import {
  Text,
  View,
} from 'react-native';

const nativeModule = NativeModules.PlusYtx ;



export default class PlusYtx extends Component {

  componentWillMount() {
    nativeModule.testPrint("aaaddddvff");
  }

  

  render() {
    

    return <Text>abcd</Text>;
  }

  
}


