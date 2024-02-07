@isTest
public with sharing class uppercaseFirstCharactersInvocableTest {
   @isTest
    static void testUppercaseFirstAfterSpace() {
        // Test with a non-empty string
        uppercaseFirstCharactersInvocable.InputParameter input1 = new uppercaseFirstCharactersInvocable.InputParameter();
        input1.inputString = 'hello world';

        uppercaseFirstCharactersInvocable.OutputParameter output1 = new uppercaseFirstCharactersInvocable.OutputParameter();
        output1.resultString = 'Hello World';

        // Test with an empty string
        uppercaseFirstCharactersInvocable.InputParameter input2 = new uppercaseFirstCharactersInvocable.InputParameter();
        input2.inputString = '';

        uppercaseFirstCharactersInvocable.OutputParameter output2 = new uppercaseFirstCharactersInvocable.OutputParameter();
        output2.resultString = '';

        // Test with a null string
        uppercaseFirstCharactersInvocable.InputParameter input3 = new uppercaseFirstCharactersInvocable.InputParameter();
        input3.inputString = null;

        uppercaseFirstCharactersInvocable.OutputParameter output3 = new uppercaseFirstCharactersInvocable.OutputParameter();
        output3.resultString = null;

        // Invoke the method with test data
        Test.startTest();
        List<uppercaseFirstCharactersInvocable.InputParameter> inputList = new List<uppercaseFirstCharactersInvocable.InputParameter>{input1, input2, input3};
        List<uppercaseFirstCharactersInvocable.OutputParameter> outputList = uppercaseFirstCharactersInvocable.uppercaseFirstAfterSpace(inputList);
        Test.stopTest();

        // Verify the results
        System.assertEquals(3, outputList.size());
        System.assertEquals(output1.resultString, outputList[0].resultString);
        System.assertEquals(output2.resultString, outputList[1].resultString);
        System.assertEquals(output3.resultString, outputList[2].resultString);
    }
}