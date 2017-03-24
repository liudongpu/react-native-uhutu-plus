import React, { Component, PropTypes } from 'react';
import {
  Text,
  View,
  NativeModules
} from 'react-native';

const nativeModule = NativeModules.UhutuPlus ;



export default class PlusYtx extends Component {

  componentWillMount() {
    nativeModule.testPrint("aaaddddvff",{a:'aaba'});
  }

  

  render() {
    

    return <Text>abcd</Text>;
  }

  
}


